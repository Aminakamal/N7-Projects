package renderer.core.mesh;

import java.awt.Color;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;

import javax.imageio.ImageIO;

/**
 * 2D Texture class.
 */
public class Texture {

    /**
     * The width of the texture.
     */
    private final int width;
    /**
     * The height of the texture.
     */
    private final int height;
    /**
     * The image of the texture.
     */
    private final BufferedImage image;

    /**
     * Constructs a new Texture with the content of the image at @path.
     * @param path the path to the image file
     * @throws IOException if the image file is not found
     */
    public Texture(String path) throws IOException {
        image = ImageIO.read(new File(path));
        width = image.getWidth();
        height = image.getHeight();
    }

    /**
     * Samples the texture at texture coordinates (u,v), using nearest neighbor
     * interpolation.
     * u and v are normalized with respect to each image dimension and may be greater
     * than 1 when the texture is repeated over a face.
     * @param u the u texture coordinate
     * @param v the v texture coordinate
     * @return the color of the texture at (u,v)
     */
    public Color sample(double u, double v) {
        // Points QCM / démo:
        // - u et v peuvent sortir de [0, 1]
        // - on applique du tiling / wrapping
        // - sampling ici en nearest-neighbor
        // Tiling: si u ou v sortent de [0, 1], on répète la texture.
        // Exemple: 1.2 -> 0.2, 2.7 -> 0.7.
        final double wrappedU = u - Math.floor(u);
        final double wrappedV = v - Math.floor(v);

        // Conversion des coordonnées normalisées en indices pixel texture.
        int x = (int) Math.floor(wrappedU * width);
        int y = (int) Math.floor(wrappedV * height);

        if (x >= width) {
            x = width - 1;
        }
        if (y >= height) {
            y = height - 1;
        }

        // Nearest-neighbor: on prend directement le pixel le plus proche.
        return new Color(image.getRGB(x, y));
    }
}
