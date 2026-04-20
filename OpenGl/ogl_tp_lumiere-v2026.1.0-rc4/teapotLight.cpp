// for mac osx
#ifdef __APPLE__

#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#include <GLUT/glut.h>

#else
// only for windows
#ifdef _WIN32
#include <windows.h>
#endif
// for windows and linux
#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/freeglut.h>
#endif

#include <cstdlib>

bool wired = false;

// function called every time the windows is refreshed
void display() {

    // clear window
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    GLfloat mat_specular[] = { 1., 1., 1., 1. }; // define the specular component
    GLfloat mat_shininess[] = { 50. }; // define the shininess
    // assign the material property
    glMaterialfv(GL_FRONT, GL_SPECULAR, mat_specular);
    glMaterialfv(GL_FRONT, GL_SHININESS, mat_shininess);








    // draw scene
    if (wired)
        glutWireTeapot(.5);
    else
        glutSolidTeapot(.5);

    // flush drawing routines to the window
    glFlush();

}

// Function called every time a key is pressed
void key(unsigned char key, int, int) 
{
    switch (key) 
    {
        case 27:
        case 'q':
            exit(EXIT_SUCCESS);
            break;
        case 'w':
        case 'W':
            wired = !wired;
            break;
        default:
            break;
    }
    // marks the current window as needing to be redisplayed.
    glutPostRedisplay();
}


// Function called every time the main window is resized
void reshape(int width, int height) {

    // define the viewport transformation;
    glViewport(0, 0, width, height);
    if (width < height)
        glViewport(0, (height - width) / 2, width, width);
    else
        glViewport((width - height) / 2, 0, height, height);
}


// Main routine
int main(int argc, char *argv[]) {

    // initialize GLUT, using any command line parameters passed to the
    //   program
    glutInit(&argc, argv);

    // setup the size, position, and display mode for new windows
    glutInitWindowSize(500, 500);
    glutInitWindowPosition(0, 0);
    glutInitDisplayMode(GLUT_RGB | GLUT_DEPTH);

    // create and set up a window
    glutCreateWindow("Hello, teapot!");

    // Set up the callback functions
    // for display
    glutDisplayFunc(display);
    // for the keyboard
    glutKeyboardFunc(key);
    // for reshaping
    glutReshapeFunc(reshape);

    // define the projection transformation
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(60, 1, 1, 10);
    // define the viewing transformation
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(1., 2.2, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);


    GLfloat light_ambient[] = { .0, .0, .0, 1. }; // the ambient component
    GLfloat light_diffuse[] = { 1., 1., 1., 1. }; // the diffuse component
    GLfloat light_specular[] = { 1., 1., 1., 1. }; // the specular component
    GLfloat light_position[] = { 1., 1., 1., .0 }; // the light position

    // set the components to the first light
    glLightfv(GL_LIGHT0, GL_AMBIENT, light_ambient);
    glLightfv(GL_LIGHT0, GL_DIFFUSE, light_diffuse);
    glLightfv(GL_LIGHT0, GL_SPECULAR, light_specular);
    glLightfv(GL_LIGHT0, GL_POSITION, light_position);

    // activate lighting effects
    glEnable(GL_LIGHTING);
    // turn on the first light
    glEnable(GL_LIGHT0);

    glEnable(GL_DEPTH_TEST);


    GLfloat ambient_light[] = { .2f, .2f, .2f, 1.f };
    glLightModelfv(GL_LIGHT_MODEL_AMBIENT, ambient_light);















    // tell GLUT to wait for events
    glutMainLoop();
}
