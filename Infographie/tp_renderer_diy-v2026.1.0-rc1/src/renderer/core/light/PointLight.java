package renderer.core.light;

import renderer.algebra.Vector;

public class PointLight extends Light {

    /**
     * The first coordinate.
     */
    private double x;

    /**
     * The second coordinate.
     */
    private double y;

    /**
     * The third coordinate.
     */
    private double z;

    /**
     * Adds a new point light source of intensity @id at position (x, y, z)
     * to the environment.
     *
     * @param x  the x coordinate of the light source
     * @param y  the y coordinate of the light source
     * @param z  the z coordinate of the light source
     * @param id the intensity of the light source
     */
    public PointLight(double x, double y, double z, double id) {
        super(id);
        this.x = x;
        this.y = y;
        this.z = z;
    }

    @Override
    public double getContribution(Vector position, Vector normal, double[] color,
            Vector cameraPosition, double ka, double kd, double ks, double s) {
        double I = 0;
        // Points QCM / démo:
        // - l = direction lumière, e = direction vue, h = bisecteur
        // - diffuse = Id * Kd * max(0, n.l)
        // - specular = Id * Ks * max(0, h.n)^s
        // n = normale unitaire au point.
        Vector n = normal.normalize();
        // e = direction vue (point -> caméra).
        Vector e = cameraPosition.subtract(position);
        e = e.normalize();

        // l = direction lumière (point -> source).
        Vector l = getPositionAsVector().subtract(position);
        l = l.normalize();

        // h = bisecteur de e et l (modèle de Blinn-Phong).
        Vector h = e.add(l);
        h = h.normalize();

        // Diffuse: Id * Kd * max(0, n.l)
        double cosNL = Math.max(0, n.dot(l));
        double I_diffuse = intensity * kd * cosNL;

        // Spéculaire: Id * Ks * max(0, h.n)^s
        double cosHN =Math.max(0, h.dot(n));
        double I_specular = intensity * ks * Math.pow(cosHN, 0);

         I += I_diffuse + I_specular;

        return I;
    }

    private Vector getPositionAsVector() {
        return new Vector(x, y, z);
    }

}
