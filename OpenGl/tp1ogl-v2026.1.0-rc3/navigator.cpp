#include <algorithm>
#include <cmath>
#include <cstdlib>

// for mac osx
#ifdef __APPLE__
#include <GLUT/glut.h>
#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#else
// only for windows
#ifdef _WIN32
#include <windows.h>
#endif
// for windows and linux
#include <GL/freeglut.h>
#include <GL/gl.h>
#include <GL/glu.h>
#endif

namespace {

constexpr float kSpeed = 0.1f;
constexpr float kAngularSpeed = 1.0f;
constexpr float kPitchLimit = 89.0f;
constexpr float kDegToRad = 3.14159265358979323846f / 180.0f;

float camera_x{0.0f};
float camera_y{0.0f};
float camera_z{5.0f};
float camera_pitch{0.0f};
float camera_yaw{0.0f};

void place_camera()
{
    // On construit le vecteur avant de la caméra à partir du yaw/pitch courants.
    // gluLookAt transforme ensuite la position et la direction en matrice de vue.
    const float pitch = camera_pitch * kDegToRad;
    const float yaw = camera_yaw * kDegToRad;

    const float forward_x = std::cos(pitch) * std::sin(yaw);
    const float forward_y = std::sin(pitch);
    const float forward_z = -std::cos(pitch) * std::cos(yaw);

    gluLookAt(camera_x,
              camera_y,
              camera_z,
              camera_x + forward_x,
              camera_y + forward_y,
              camera_z + forward_z,
              0.0,
              1.0,
              0.0);
}

void draw_scene()
{
    glPushMatrix();

        glPushMatrix();
            glTranslatef(0.0f, 0.0f, -3.0f);
            glColor3f(1.0f, 0.0f, 0.0f);
            glutWireTeapot(1.0);
            glTranslatef(0.0f, 2.0f, 0.0f);
            glColor3f(0.0f, 1.0f, 0.0f);
            glRotatef(90.0f, 1.0f, 0.0f, 0.0f);
            glutWireTeapot(1.0);
        glPopMatrix();

        glTranslatef(0.0f, -2.0f, -1.0f);
        glColor3f(0.0f, 0.0f, 1.0f);
        glutWireTeapot(1.0);

    glPopMatrix();
}

} // namespace

void display()
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    // La matrice de vue est construite ici, puis la scène est dessinée dans l'espace caméra.
    place_camera();

    draw_scene();

    glFlush();
}

void key(unsigned char key, int, int)
{
    switch (key) {
        case 27:
            std::exit(EXIT_SUCCESS);
            break;
        case 'w':
        case 'W':
            camera_z -= kSpeed;
            break;
        case 's':
        case 'S':
            camera_z += kSpeed;
            break;
        case 'a':
        case 'A':
            camera_x -= kSpeed;
            break;
        case 'd':
        case 'D':
            camera_x += kSpeed;
            break;
        case 'q':
        case 'Q':
            camera_y += kSpeed;
            break;
        case 'z':
        case 'Z':
            camera_y -= kSpeed;
            break;
        default:
            break;
    }

    glutPostRedisplay();
}

void special_key(int key, int, int)
{
    switch (key) {
        case GLUT_KEY_LEFT:
            camera_yaw += kAngularSpeed;
            break;
        case GLUT_KEY_RIGHT:
            camera_yaw -= kAngularSpeed;
            break;
        case GLUT_KEY_UP:
            camera_pitch += kAngularSpeed;
            if (camera_pitch > kPitchLimit) {
                camera_pitch = kPitchLimit;
            }
            break;
        case GLUT_KEY_DOWN:
            camera_pitch -= kAngularSpeed;
            if (camera_pitch < -kPitchLimit) {
                camera_pitch = -kPitchLimit;
            }
            break;
        default:
            break;
    }

    glutPostRedisplay();
}

void reshape(int width, int height)
{
    glViewport(0, 0, width, height);
    // On garde la projection cohérente avec le rapport largeur/hauteur quand la fenêtre change.
}

int main(int argc, char* argv[])
{
    glutInit(&argc, argv);
    glutInitWindowSize(500, 500);
    glutInitWindowPosition(0, 0);
    glutInitDisplayMode(GLUT_RGB | GLUT_DEPTH);

    glutCreateWindow("navigator");

    glutDisplayFunc(display);
    glutKeyboardFunc(key);
    glutSpecialFunc(special_key);
    glutReshapeFunc(reshape);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    // Ici, la projection est fixée une fois; la vue est mise à jour à chaque image dans display().
    gluPerspective(45.0, 1.0, 2.2, 10.0);

    glEnable(GL_DEPTH_TEST);

    glutMainLoop();
}