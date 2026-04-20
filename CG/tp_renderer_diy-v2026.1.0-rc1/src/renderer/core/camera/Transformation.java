package renderer.core.camera;

import renderer.algebra.Matrix;
import renderer.algebra.SizeMismatchException;
import renderer.algebra.Vector;


/**
 * The Transformation class represents a transformation in 3D space.
 * author: cdehais
 */
public class Transformation {

    /**
     * The world to camera matrix.
     */
    private Matrix worldToCamera;
    /**
     * The 3x4 projection matrix.
     */
    private Matrix projection;
    /**
     * The 3x3 calibration matrix.
     */
    private Matrix calibration;

    /**
     * Creates a new Transformation object.
     */
    public Transformation() {
        final int w2cDim = 4;
        worldToCamera = Matrix.createIdentity("W2C", w2cDim);
        final int projRows = 3;
        final int projCols = 4;
        projection = new Matrix("P", projRows, projCols);
        final int calibDim = 3;
        calibration = Matrix.createIdentity("K", calibDim);
    }

    /**
     * Sets the lookAt transformation.
     * @param eye a 3D vector representing the eye position
     * @param lookAtPoint a 3D vector representing the point to look at
     * @param up a 3D vector representing the up direction
     */
    public void setLookAt(final Vector eye, final Vector lookAtPoint, final Vector up) {
        try {
            // Points QCM / démo:
            // - base caméra orthonormée = (right, upCorrect, forward)
            // - translation = -dot(axe_camera, eye)
            // - piège classique: erreur de signe dans la translation
            // Base camera:
            // forward = direction de vue,
            // right = axe horizontal caméra,
            // upCorrect = axe vertical caméra recalculé pour obtenir une base orthonormée.
            Vector forward = lookAtPoint.subtract(eye);
            forward= forward.normalize();
            Vector right = up.cross(forward);
            right = right.normalize();
            Vector upCorrect = forward.cross(right);
            upCorrect = upCorrect.normalize();
            // Rotation monde -> caméra.
            worldToCamera.set(0, 0, right.get(0));
            worldToCamera.set(0, 1, right.get(1));
            worldToCamera.set(0, 2, right.get(2));
               
            worldToCamera.set(1, 0, upCorrect.get(0));
            worldToCamera.set(1, 1, upCorrect.get(1));
            worldToCamera.set(1, 2, upCorrect.get(2));
  
            worldToCamera.set(2, 0, forward.get(0));
            worldToCamera.set(2, 1, forward.get(1));
            worldToCamera.set(2, 2, forward.get(2));
            // Translation = -dot(axe_camera, eye).
            // Cela revient à exprimer le point (p - eye) dans la base caméra.
            worldToCamera.set(0, 3, -right.dot(eye));
            worldToCamera.set(1, 3, -upCorrect.dot(eye));
            worldToCamera.set(2, 3, -forward.dot(eye));
            worldToCamera.set(3, 3, 1.0);
        } catch (Exception e) {
            e.printStackTrace();
        }

        System.out.println("Modelview matrix:\n" + worldToCamera);
    }

    /**
     * Sets the projection matrix.
     */
    public void setProjection() {
        // Ici on conserve (Xc, Yc, Zc) avant la division perspective.
        // La vraie perspective sera obtenue ensuite en divisant par z.
        projection.set(0, 0, 1.0);
        projection.set(0, 1, 0.0);
        projection.set(0, 2, 0.0);
        projection.set(0, 3, 0.0);
        
        projection.set(1, 0, 0.0);
        projection.set(1, 1, 1.0);
        projection.set(1, 2, 0.0);
        projection.set(1, 3, 0.0);
        
        projection.set(2, 0, 0.0);
        projection.set(2, 1, 0.0);
        projection.set(2, 2, 1.0);
        projection.set(2, 3, 0.0);

        System.out.println("Projection matrix:\n" + projection);
    }

    /**
     * Sets the calibration matrix.
     * @param focal the focal length
     * @param width the width of the image
     * @param height the height of the image
     */
    public void setCalibration(double focal, double width, double height) {

        // Points QCM / démo:
        // - K est la matrice intrinsèque
        // - centre image = (width/2, height/2)
        // - focal est exprimée ici en pixels

        // Matrice intrinsèque K:
        // [ f  0  cx ]
        // [ 0  f  cy ]
        // [ 0  0   1 ]
        // avec cx = width/2 et cy = height/2.

        calibration.set(0, 0, focal);
        calibration.set(0, 1, 0.0);
        calibration.set(0, 2, width / 2.0);
        calibration.set(1, 0, 0.0);
        calibration.set(1, 1, focal);
        calibration.set(1, 2, height / 2.0);
        calibration.set(2, 0, 0.0);
        calibration.set(2, 1, 0.0);
        calibration.set(2, 2, 1.0);     
        
        System.out.println("Calibration matrix:\n" + calibration);
    }

    /**
     * Projects the given 3 dimensional point onto the screen.
     * The resulting Vector as its (x,y) coordinates in pixel, and its z coordinate
     * is the depth of the point in the camera coordinate system.
     * @param p a 3d vector representing a point
     * @return the projected point as a 3d vector, with (x,y) the pixel
     * coordinates and z the depth
     * @throws SizeMismatchException if the size of the input vector is not 3
     */
    public Vector projectPoint(Vector p) throws SizeMismatchException {
        Vector ps = new Vector(3);
        // Points QCM / démo:
        // - ordre du pipeline: monde -> caméra -> projection -> calibration
        // - division perspective à la fin
        // - on conserve pc.z comme profondeur pour le z-buffer
        
        // Passage en homogène: Pw = (x, y, z, 1).
        Vector pH = new Vector(4);
        pH.set(0, p.get(0));
        pH.set(1, p.get(1));
        pH.set(2, p.get(2));
        pH.set(3, 1.0);
        // 1) Monde -> caméra.
        Vector pc = worldToCamera.multiply(pH);       
        // 2) Projection canonique.
        Vector pp = projection.multiply(pc);     
        // 3) Passage en coordonnées image via K.
        Vector pScreen = calibration.multiply(pp);    
        // 4) Division perspective: (u, v) = (x/z, y/z).
        // Important: on conserve pc.z comme profondeur pour le z-buffer.
        double z = pScreen.get(2);  
        ps.set(0, pScreen.get(0) / z);
        ps.set(1, pScreen.get(1) / z);
        ps.set(2, pc.get(2));
        
        return ps;
    }

    /**
     * Transform a vector from world to camera coordinates.
     * @param v the vector to transform
     * @return the transformed vector
     * @throws SizeMismatchException if the size of the input vector is not 3
     */
    public Vector transformVector(final Vector v) {
        // Doing nothing special here because there is no scaling
        final Matrix m = worldToCamera.getSubMatrix(0, 0, 3, 3);
        return m.multiply(v);
    }

}
