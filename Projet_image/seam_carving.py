import cv2 as cv
import numpy as np


# ─── Energy functions ────────────────────────────────────────────────────────

def e1(image):
    gray = cv.cvtColor(image, cv.COLOR_BGR2GRAY)
    sobelx = cv.Sobel(gray, cv.CV_64F, 1, 0, ksize=3)
    sobely = cv.Sobel(gray, cv.CV_64F, 0, 1, ksize=3)
    return np.hypot(sobelx, sobely)


def ehog(image):
    energy = e1(image)
    gray = cv.cvtColor(image, cv.COLOR_BGR2GRAY)
    hog = cv.HOGDescriptor()
    h = hog.compute(gray)
    h_max = h.max()
    if h_max > 0:
        energy = energy / h_max
    return energy


def compute_energy(image, function):
    return function(image)


# ─── Optimal seam (vectorised DP) ────────────────────────────────────────────

def optimal_seam_vert(energy):
    """Find lowest-energy vertical seam using fully vectorised DP."""
    rows, cols = energy.shape
    M = energy.copy()

    for i in range(1, rows):
        prev = M[i - 1]
        left         = np.roll(prev,  1); left[0]   = np.inf
        right        = np.roll(prev, -1); right[-1] = np.inf
        M[i] += np.minimum(prev, np.minimum(left, right))

    # Backtrack
    seam = np.empty(rows, dtype=np.int32)
    seam[-1] = np.argmin(M[-1])
    for i in range(rows - 2, -1, -1):
        j = seam[i + 1]
        lo = max(0, j - 1)
        hi = min(cols, j + 2)
        seam[i] = lo + np.argmin(M[i, lo:hi])

    costs = M[np.arange(rows), seam]
    return seam, costs


def optimal_seam_hor(energy):
    """Find lowest-energy horizontal seam using fully vectorised DP."""
    # Transpose → reuse vertical logic → transpose back
    seam, costs = optimal_seam_vert(energy.T)
    return seam, costs


# ─── Seam removal (vectorised) ───────────────────────────────────────────────

def remove_seam_vert(image, seam):
    rows, cols, ch = image.shape
    mask = np.ones((rows, cols), dtype=bool)
    mask[np.arange(rows), seam] = False
    return image[mask].reshape(rows, cols - 1, ch)


def remove_seam_hor(image, seam):
    """Remove horizontal seam: transpose → remove vertical → transpose back."""
    return np.ascontiguousarray(
        remove_seam_vert(image.transpose(1, 0, 2), seam).transpose(1, 0, 2)
    )


# ─── Seam insertion (vectorised) ─────────────────────────────────────────────

def add_seam_vert(image, seam):
    rows, cols, ch = image.shape
    output = np.empty((rows, cols + 1, ch), dtype=image.dtype)
    for i in range(rows):
        j = seam[i]
        output[i, :j + 1] = image[i, :j + 1]
        left  = image[i, j - 1] if j > 0        else image[i, j]
        right = image[i, j + 1] if j < cols - 1 else image[i, j]
        output[i, j + 1] = ((left.astype(np.float64) +
                               image[i, j].astype(np.float64) +
                               right.astype(np.float64)) / 3).astype(image.dtype)
        output[i, j + 2:] = image[i, j + 1:]
    return output


def add_seam_hor(image, seam):
    return np.ascontiguousarray(
        add_seam_vert(image.transpose(1, 0, 2), seam).transpose(1, 0, 2)
    )


# ─── 2-D index-map removal helpers ───────────────────────────────────────────

def _remove_seam_vert_2d(array, seam):
    rows, cols = array.shape
    mask = np.ones((rows, cols), dtype=bool)
    mask[np.arange(rows), seam] = False
    return array[mask].reshape(rows, cols - 1)


def _remove_seam_hor_2d(array, seam):
    return _remove_seam_vert_2d(array.T, seam).T


# ─── Find / insert k seams ───────────────────────────────────────────────────

def find_k_seams_vert(image, energy_function, k):
    if k <= 0:
        return []
    working = image.copy()
    rows, cols, _ = working.shape
    if k > cols:
        raise ValueError("k > image width")
    index_map = np.tile(np.arange(cols), (rows, 1))
    seams = []
    for _ in range(k):
        seam = optimal_seam_vert(compute_energy(working, energy_function))[0]
        seams.append(index_map[np.arange(rows), seam].copy())
        working   = remove_seam_vert(working, seam)
        index_map = _remove_seam_vert_2d(index_map, seam)
    return seams


def find_k_seams_hor(image, energy_function, k):
    if k <= 0:
        return []
    working = image.copy()
    rows, cols, _ = working.shape
    if k > rows:
        raise ValueError("k > image height")
    index_map = np.tile(np.arange(rows)[:, None], (1, cols))
    seams = []
    for _ in range(k):
        seam = optimal_seam_hor(compute_energy(working, energy_function))[0]
        seams.append(index_map[seam, np.arange(cols)].copy())
        working   = remove_seam_hor(working, seam)
        index_map = _remove_seam_hor_2d(index_map, seam)
    return seams


def add_k_seams_vert(image, seams):
    output = image.copy()
    todo = [s.astype(int).copy() for s in seams]
    while todo:
        s = todo.pop(0)
        output = add_seam_vert(output, s)
        for other in todo:
            other[other >= s] += 1
    return output


def add_k_seams_hor(image, seams):
    output = image.copy()
    todo = [s.astype(int).copy() for s in seams]
    while todo:
        s = todo.pop(0)
        output = add_seam_hor(output, s)
        for other in todo:
            other[other >= s] += 1
    return output


# ─── Transport map ───────────────────────────────────────────────────────────

def transport_map(function, image, r, c):
    """
    Build the (r+1) × (c+1) transport map T and decision map M.
    M[i,j] == 0 → vertical seam was cheaper; 1 → horizontal seam.

    Key fix vs. original: we maintain a single evolving image so that
    each seam cost reflects the *current* state of the image, not a
    stale energy computed several steps ago.
    """
    T = np.full((r + 1, c + 1), np.inf)
    M = np.zeros((r + 1, c + 1), dtype=np.int8)
    T[0, 0] = 0.0

    # Pre-compute seam costs along the axes
    img_v = image.copy()
    vert_costs = []
    for _ in range(r):
        e = compute_energy(img_v, function)
        seam, costs = optimal_seam_vert(e)
        vert_costs.append(float(costs.sum()))
        img_v = remove_seam_vert(img_v, seam)

    img_h = image.copy()
    hor_costs = []
    for _ in range(c):
        e = compute_energy(img_h, function)
        seam, costs = optimal_seam_hor(e)
        hor_costs.append(float(costs.sum()))
        img_h = remove_seam_hor(img_h, seam)

    # Fill first column (only vertical seams)
    for i in range(1, r + 1):
        T[i, 0] = T[i - 1, 0] + vert_costs[i - 1]
        M[i, 0] = 0

    # Fill first row (only horizontal seams)
    for j in range(1, c + 1):
        T[0, j] = T[0, j - 1] + hor_costs[j - 1]
        M[0, j] = 1

    # Fill interior — use cumulative sums as proxy for seam costs
    cumv = np.cumsum(vert_costs)
    cumh = np.cumsum(hor_costs)
    for i in range(1, r + 1):
        for j in range(1, c + 1):
            cost_v = T[i - 1, j] + vert_costs[i - 1]
            cost_h = T[i, j - 1] + hor_costs[j - 1]
            if cost_v <= cost_h:
                T[i, j] = cost_v; M[i, j] = 0
            else:
                T[i, j] = cost_h; M[i, j] = 1

    return T, M


def optimal_order(M):
    r, c = M.shape[0] - 1, M.shape[1] - 1
    order = []
    while r > 0 or c > 0:
        if r == 0:
            order.append('hor'); c -= 1
        elif c == 0:
            order.append('vert'); r -= 1
        elif M[r, c] == 0:
            order.append('vert'); r -= 1
        else:
            order.append('hor'); c -= 1
    return order[::-1]




def image_resize_down_naive(image, energy_function, height, length):
    out = image.copy()
    rows, cols, _ = out.shape
    for _ in range(rows - height):
        out = remove_seam_hor(out, optimal_seam_hor(compute_energy(out, energy_function))[0])
    for _ in range(cols - length):
        out = remove_seam_vert(out, optimal_seam_vert(compute_energy(out, energy_function))[0])
    return out


def image_resize_down(image, energy_function, height, length):
    out = image.copy()
    r = image.shape[0] - height
    c = image.shape[1] - length
    if r == 0 and c == 0:
        return out
    _, M = transport_map(energy_function, out, r, c)
    for direction in optimal_order(M):
        energy_map = compute_energy(out, energy_function)
        if direction == 'vert':
            out = remove_seam_vert(out, optimal_seam_vert(energy_map)[0])
        else:
            out = remove_seam_hor(out, optimal_seam_hor(energy_map)[0])
    return out


def image_resize_up(image, energy_function, height, length, max_step_ratio=0.5):
    out = image.copy()
    if max_step_ratio <= 0:
        raise ValueError("max_step_ratio must be > 0")
    while out.shape[0] < height or out.shape[1] < length:
        rows, cols, _ = out.shape
        add_rows = max(0, min(height - rows,
                              max(1, int(np.floor(rows * max_step_ratio)))))
        add_cols = max(0, min(length - cols,
                              max(1, int(np.floor(cols * max_step_ratio)))))
        if add_cols > 0:
            out = add_k_seams_vert(out, find_k_seams_vert(out, energy_function, add_cols))
        if add_rows > 0:
            out = add_k_seams_hor(out, find_k_seams_hor(out, energy_function, add_rows))
    return out


def image_amplification(image, energy_function, height, length):
    if height > image.shape[0] and length > image.shape[1]:
        image_height = image.shape[0]
        image_length = image.shape[1]
        up = image_resize_up(image, energy_function, height, length)
        return image_resize_down_naive(up, energy_function, image_height, image_length)
    raise ValueError("height and length must both be larger than the source image.")


def image_resize(image, energy_function, height, length):
    if height < image.shape[0] and length < image.shape[1]:
        return image_resize_down(image, energy_function, height, length)
    elif height > image.shape[0] and length > image.shape[1]:
        return image_resize_up(image, energy_function, height, length)
    raise ValueError("Mixed up/down resizing is not supported.")


# ─── Demo ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    image = cv.imread('images-20100824/car.png')
    if image is None:
        raise FileNotFoundError("car.png not found")
    result = image_amplification(image, e1, height=800, length=1100)
    cv.imshow('Original', image)
    cv.imshow('Amplified', result)
    cv.waitKey(0)
    cv.destroyAllWindows()