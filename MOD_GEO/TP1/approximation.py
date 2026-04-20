import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import math
import plotly.graph_objs as go
from scipy.spatial import ConvexHull


def t_to_evaluate(min_value: float, max_value: float, nb_samples: int) -> list:
    """
    Generates a list of `nb_samples` evenly spaced values between `min_value` and `max_value` included.

    Args:
        min_value (float): The minimum value of the range.
        max_value (float): The maximum value of the range.
        nb_samples (int): The number of values to generate.

    Returns:
        list: A list of `nb_samples` evenly spaced values between `min_value` and `max_value`.

    Raises:
        AssertionError: If `nb_samples` is not a positive integer.
    """
    assert nb_samples > 0, "nb_samples must be a positive integer"
    return np.linspace(min_value, max_value, nb_samples).tolist()


def generate_samples(nb_samples: int) -> list:
    """
    Generates the set of evaluation times from the given number of samples.

    Args:
        nb_samples (int): Number of samples.

    Returns:
        list_tt: Evaluation times.
    """
    list_tt = t_to_evaluate(0, 1, nb_samples)
    return list_tt


def k_among_n(k, n):
    """
    Compute the number of ways to choose `k` elements out of a pile of `n` elements.

    .. math::
        C_{k}^{n} = \frac{n!}{k!(n-k)!}

    Args:
        k (int): Number of successes.
        n (int): Number of trials.

    Returns:
        int: Binomial coefficient.
    """
    if not (0 <= k <= n):
        return 0
    return math.comb(n, k)


def build_polys_bernstein(max_degree, list_tt) -> list:
    """
    Build Bernstein polynomials up to degree `max_degree`.

    Args:
        max_degree (int): Maximum degree.
        list_tt (list): Evaluation times.

    Returns:
        list: A list containing `max_degree` matrices of 2D points, one for each Bernstein polynomial.
              Each matrix contains `len(list_tt)` points.
    """
    liste_points = []
    for k in range(max_degree + 1):
        matrix_points = np.zeros((len(list_tt), 2))
        for t_index, t in enumerate(list_tt):
            binomial = k_among_n(k, max_degree)
            y = binomial * (t ** k) * ((1 - t) ** (max_degree - k))
            matrix_points[t_index, 0] = t
            matrix_points[t_index, 1] = y
        liste_points.append(matrix_points)
    return liste_points


def bezier_bernstein(x_ctrl_pts: list[float], y_ctrl_pts: list[float], list_t: list[float]) -> np.ndarray:
    """
    Calculates the points reached by the Bezier curve at each evaluation time.

    Args:
        x_ctrl_pts (list of float): Abscissas of control points.
        y_ctrl_pts (list of float): Ordinates of control points.
        list_t (list of float): Evaluation times.

    Returns:
        array: 2D coordinates of the points of the curve, with dimensions (len(list_t), 2).
    """
    deg_max = len(x_ctrl_pts) - 1
    base = build_polys_bernstein(deg_max, list_t)
    result = np.zeros((len(list_t), 2))

    for i in range(deg_max + 1):
        bernstein_values = base[i][:, 1]
        result[:, 0] += x_ctrl_pts[i] * bernstein_values
        result[:, 1] += y_ctrl_pts[i] * bernstein_values

    return result


def de_casteljau1D(dd, tt):
    """
    Applies the De Casteljau algorithm on the values of `DD` for a curve defined by control points.

    Args:
        dd (list of float): List of values to approximate (abscissas or ordinates).
        tt (float): Evaluation time.

    Returns:
        float: Approximated value (abscissa or ordinate) at `tt`.
    """
    values = np.array(dd, dtype=float).copy()
    n = len(values)

    for level in range(1, n):
        for i in range(n - level):
            values[i] = (1 - tt) * values[i] + tt * values[i + 1]

    return float(values[0])


def de_casteljau(dd, tt):
    """Backward-compatible alias used by utility scripts."""
    return de_casteljau1D(dd, tt)


def de_casteljau2D(x_ctrl_pts: list[float], y_ctrl_pts: list[float], tt: float) -> tuple:
    """
    Applies the De Casteljau algorithm on the values of `x_ctrl_pts` and `y_ctrl_pts` for a curve defined by control points.

    Args:
        x_ctrl_pts (list of float): Abscissas of control points.
        y_ctrl_pts (list of float): Ordinates of control points.
        tt (float): Evaluation time.

    Returns:
        array: 2D coordinates of a point of the curve at parameter tt
    """
    x_val = de_casteljau1D(x_ctrl_pts, tt)
    y_val = de_casteljau1D(y_ctrl_pts, tt)
    return np.array([x_val, y_val])


def subdivision(x: list, y: list) -> tuple:
    """
    Performs one step of subdivision.

    Args:
        x (list of float): Abscissas of control points.
        y (list of float): Ordinates of control points.

    Returns:
        tuple: Lists containing the abscissas and ordinates of the two new families Q and R.
    """
    n = len(x)
    qx, qy, rx, ry = [x[0]], [y[0]], [x[-1]], [y[-1]]

    work_x = [float(v) for v in x]
    work_y = [float(v) for v in y]

    for level in range(1, n):
        next_x, next_y = [], []
        for i in range(n - level):
            next_x.append(0.5 * (work_x[i] + work_x[i + 1]))
            next_y.append(0.5 * (work_y[i] + work_y[i + 1]))

        qx.append(next_x[0])
        qy.append(next_y[0])
        rx.append(next_x[-1])
        ry.append(next_y[-1])
        work_x, work_y = next_x, next_y

    rx.reverse()
    ry.reverse()
    return qx, qy, rx, ry


def de_casteljau_subdivision(x, y, num_subdivisions):
    """
    Returns the list of points composing the approximating curve according to a given number of subdivisions.

    Args:
        x (list of float): Abscissas of control points.
        y (list of float): Ordinates of control points.
        num_subdivisions (int): Number of subdivisions.

    Returns:
        tuple: Lists with the abscissas and ordinates of the points of the curve.
    """

    def aux(lx: list[float], ly: list[float], nb: int) -> tuple:
        """
        Recursive function to subdivide the curve.

        Args:
            lx: list of float representing the x coordinates of the control points
            ly: list of float representing the y coordinates of the control points
            nb: current subdivision level

        Returns:
            tuple: Lists with the abscissas and ordinates of the subdivided curve.
        """
        if nb <= 0 or len(lx) <= 1:
            return list(lx), list(ly)

        qx, qy, rx, ry = subdivision(lx, ly)
        left_x, left_y = aux(qx, qy, nb - 1)
        right_x, right_y = aux(rx, ry, nb - 1)

        return left_x[:-1] + right_x, left_y[:-1] + right_y

    return aux(x, y, num_subdivisions)


def approximation_surface(xx, yy, zz, list_tt, nb_grid_pts):
    """
    Calculates the points reached by the surface at each evaluation time.

    Args:
        xx (array of float): X coordinates of 3D control points.
        yy (array of float): Y coordinates of 3D control points.
        zz (array of float): Z coordinates of 3D control points.
        list_tt (list of float): Evaluation times. Same list of parameters for the two dimensions
        nb_grid_pts (int): Number of grid points. Same number of grid points in the two dimensions,
                           so, an array of size (nb_grid_pts, nb_grid_pts) of control points.

    Returns:
        array: 3D coordinates of the approximated surface points, with dimensions (nb_echantillon, nb_echantillon, 3).
    """
    n = len(list_tt)
    approximated_surface = np.zeros((n, n, 3))  # Surfaces

    for u_idx, u in enumerate(list_tt):
        for v_idx, v in enumerate(list_tt):
            x_intermediate = [de_casteljau1D(xx[row, :], v) for row in range(nb_grid_pts)]
            y_intermediate = [de_casteljau1D(yy[row, :], v) for row in range(nb_grid_pts)]
            z_intermediate = [de_casteljau1D(zz[row, :], v) for row in range(nb_grid_pts)]

            approximated_surface[u_idx, v_idx, 0] = de_casteljau1D(x_intermediate, u)
            approximated_surface[u_idx, v_idx, 1] = de_casteljau1D(y_intermediate, u)
            approximated_surface[u_idx, v_idx, 2] = de_casteljau1D(z_intermediate, u)

    return approximated_surface


# BONUS HODOGRAPH

def hodograph(x_ctrl_pts: list[float], y_ctrl_pts: list[float], nb_samples: int):
    """
    BONUS HODOGRAPH: Calculates and plots the hodograph of a curve.

    Args:
        x_ctrl_pts (list of float): Abscissas of control points.
        y_ctrl_pts (list of float): Ordinates of control points.
        nb_samples (int): Number of samples.

    Returns:
        None
    """
    list_t = generate_samples(nb_samples=nb_samples)
    n = len(x_ctrl_pts) - 1
    list_points = [de_casteljau2D(x_ctrl_pts, y_ctrl_pts, tt) for tt in list_t]

    if n <= 0:
        x_ctrl_pts_bis = [0.0]
        y_ctrl_pts_bis = [0.0]
        list_points_bis = [np.array([0.0, 0.0]) for _ in list_t]
    else:
        x_ctrl_pts_bis = [n * (x_ctrl_pts[i + 1] - x_ctrl_pts[i]) for i in range(n)]
        y_ctrl_pts_bis = [n * (y_ctrl_pts[i + 1] - y_ctrl_pts[i]) for i in range(n)]
        list_points_bis = [de_casteljau2D(x_ctrl_pts_bis, y_ctrl_pts_bis, tt) for tt in list_t]

    # Display the hodograph - DO NOT CHANGE
    plt.figure(figsize=(12, 6))
    list_points = np.array(list_points)
    list_points_bis = np.array(list_points_bis)

    plt.subplot(1, 2, 1)
    points = np.zeros((len(x_ctrl_pts), 2))
    points[:, 0], points[:, 1] = x_ctrl_pts, y_ctrl_pts

    plt.plot(list_points[:, 0], list_points[:, 1])
    plt.plot(x_ctrl_pts, y_ctrl_pts, color='red', marker='o', linestyle='--', linewidth=0.5,
             label='hodograph curve')
    plt.scatter(x_ctrl_pts, y_ctrl_pts)
    plt.title('De Casteljau Approximation')

    plt.subplot(1, 2, 2)

    plt.plot(list_points_bis[:, 0], list_points_bis[:, 1])
    plt.plot(x_ctrl_pts_bis, y_ctrl_pts_bis, color='green', marker='o', linestyle='--', linewidth=0.5,
             label="hodograph control points")
    for i in range(len(points[:, 0]) - 1):
        plt.plot([0, len(x_ctrl_pts) * (points[i + 1, 0] - points[i, 0])],
                 [0, len(y_ctrl_pts) * (points[i + 1, 1] - points[i, 1])], color='orange', linestyle='--',
                 linewidth=0.25, label='vector Pi+1 Pi')

    plt.scatter(x_ctrl_pts_bis, y_ctrl_pts_bis)
    plt.scatter(0, 0)
    plt.title('Hodograph')
    plt.legend()

    plt.tight_layout()
    plt.show()
