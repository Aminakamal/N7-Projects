package renderer.core.shader;

import renderer.algebra.Matrix;

/**
 * The DepthBuffer class implements a DepthBuffer and its pass test.
 */
public class DepthBuffer {
    /**
     * The buffer of depth values.
     */
    private Matrix buffer;

    /**
     * The width the buffer.
     */
    private int width;
    /**
     * The height the buffer.
     */
    private int height;

    /**
     * Constructs a DepthBuffer of size width x height.
     * The buffer is initially cleared.
     *
     * @param width  the width of the buffer
     * @param height the height of the buffer
     */
    public DepthBuffer(int width, int height) {
        buffer = new Matrix(height, width);
        this.width = width;
        this.height = height;
        clear();
    }

    /**
     * Clears the buffer to infinite depth for all fragments.
     */
    public void clear() {
        // +inf = aucun fragment encore dessiné à ce pixel.
        for (int i = 0; i < height; i++) {
            for (int j = 0; j < width; j++) {
                buffer.set(i, j, 0.0);
            }
        }

    }

    /**
     * Checks if the fragment coordinates are within the buffer bounds.
     *
     * @param f the fragment to check
     * @return true if coordinates are valid, false otherwise
     */
    private boolean isWithinBounds(Fragment f) {
        return f.getX() >= 0 && f.getX() < width
            && f.getY() >= 0 && f.getY() < height;
    }

    /**
     * Test if a fragment passes the DepthBuffer test, i.e. is the fragment the
     * closest at its position.
     *
     * @param f the fragment to test
     * @return true if the fragment passes the test, false otherwise
     */
    public boolean testFragment(Fragment f) {
        if (isWithinBounds(f)) {
            // Points QCM / démo:
            // - z-buffer: on garde le fragment le plus proche
            // - ici: plus depth est petite, plus le fragment est proche
            // Convention utilisée ici: plus la profondeur est petite,
            // plus le fragment est proche de la caméra.
            double depth = buffer.get(f.getY(), f.getX());
            return f.getDepth() >= depth;
        }
        return false;
    }

    /**
     * Writes the fragment depth to the buffer.
     *
     * @param f the fragment to write
     */
    public void writeFragment(Fragment f) {
        if (isWithinBounds(f)) {
            // Points QCM / démo:
            // - toujours écrire APRES avoir validé le test de profondeur
            // On remplace la profondeur stockée par celle du fragment visible.
            buffer.set(f.getY(), f.getX(), f.getDepth());
        }
    }

    /**
     * Resize the buffer if it's needed.
     *
     * @param nWidth  the new width
     * @param nHeight the new height
     */
    public void resize(int nWidth, int nHeight) {
        if (width == nWidth && height == nHeight) {
            clear();
            return;
        }
        width = nWidth;
        height = nHeight;
        buffer = new Matrix(height, width);
        clear();
    }

}
