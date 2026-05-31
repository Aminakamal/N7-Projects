#include <cstdlib>
#include <iostream>
#include <cmath>
#include <algorithm>

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


// Global variables to animate the robotic arm
float angle1 = .0f;
float angle2 = .0f;

// Global variables to rotate the arm as a whole
float robotAngleX = .0f;
float robotAngleY = .0f;

float pincerOpening = 0.15f;

constexpr float angle_step = 5.f;
constexpr float angle_max = 360.f;
constexpr float pincer_step = 0.02f;
constexpr float pincer_min = 0.0f;
constexpr float pincer_max = 0.30f;















/**
 * Function that draws the reference system (three lines along the x, y, z axis)
 */
void drawReferenceSystem()
{
    // Preserve color/line/enable state (compat profile)
    glPushAttrib(GL_CURRENT_BIT | GL_LINE_BIT | GL_ENABLE_BIT);

    // disable lighting to ensure vertex colors are used
    //if (glIsEnabled(GL_LIGHTING)) glDisable(GL_LIGHTING);

    // thicker, longer axes for visibility
    glLineWidth(3.0f);
    const float L = 1.0f;

    // Draw three lines along the x, y, z axis to represent the reference system
    // Use red for the x-axis, green for the y-axis and blue for the z-axis
    glBegin(GL_LINES);
        // x-axis (red)
        glColor3f(0.50f, 0.0f, 0.0f);
        glVertex3f(0.0f, 0.0f, 0.0f);
        glVertex3f(L, 0.0f, 0.0f);

        // y-axis (green)
        glColor3f(0.0f, 0.50f, 0.0f);
        glVertex3f(0.0f, 0.0f, 0.0f);
        glVertex3f(0.0f, L, 0.0f);

        // z-axis (blue)
        glColor3f(0.0f, 0.0f, 0.50f);
        glVertex3f(0.0f, 0.0f, 0.0f);
        glVertex3f(0.0f, 0.0f, L);
    glEnd();

    // restore previous GL state
    glPopAttrib();
}


/**
 * Function that draws a single joint of the robotic arm
 */
void drawJoint()
{
    glPushMatrix();

    drawReferenceSystem();

    glPushMatrix();
        glTranslatef(0.0f, 0.5f, 0.0f);
        glScalef(0.5f, 1.0f, 0.5f);
        glutWireCube(1.0f);
    glPopMatrix();

    glPushMatrix();
        glTranslatef(0.0f, 1.0f, 0.0f);
        glScalef(0.16f, 0.08f, 0.32f);
        glutWireCube(1.0f);
    glPopMatrix();

    glPushMatrix();
        glTranslatef(0.0f, 1.0f, 0.0f);
        glScalef(0.12f, 0.08f, 0.12f);
        glutWireCube(1.0f);
    glPopMatrix();

    glPopMatrix();
}

/**
 * Function that draws the robot as three parallelepipeds
 */
void drawRobot()
{
    //**********************************
    // On sauvegarde la matrice MODELVIEW courante pour que chaque pièce hérite de son parent.
    //**********************************
    
    glPushMatrix();

    // Rotation globale de tout le robot avant de parcourir la chaîne articulée.
    glRotatef(robotAngleX, 1.f, 0.f, 0.f);
    glRotatef(robotAngleY, 0.f, 1.f, 0.f);
    // draw the first joint (base)
    drawJoint();

    // Chaque articulation est attachée à la précédente : on se translate jusqu'à son extrémité,
    // puis on applique la rotation locale. C'est la propagation des transformations dans l'arbre.
    const float joint_height = 1.0f;

    // Move to top of first joint, rotate and draw second joint
    glTranslatef(0.f, joint_height, 0.f);
    glRotatef(angle1, 1.f, 0.f, 0.f);
   // glRotatef(angle1, 0.f, 1.f, 0.f);
    drawJoint();

    // Move to top of second joint, rotate and draw third joint
    glTranslatef(0.f, joint_height, 0.f);
    glRotatef(angle2, 1.f, 0.f, 0.f);
    drawJoint();

    glTranslatef(0.f, joint_height, 0.f);

    glPushMatrix();
        glTranslatef(-pincerOpening, 0.1f, 0.0f);
        glScalef(0.08f, 0.35f, 0.08f);
        glutWireCube(1.0f);
    glPopMatrix();

    glPushMatrix();
        glTranslatef(pincerOpening, 0.1f, 0.0f);
        glScalef(0.08f, 0.35f, 0.08f);
        glutWireCube(1.0f);
    glPopMatrix();

    // On restaure la matrice parente pour éviter que les branches voisines héritent des enfants.
    glPopMatrix();












}


/**
 * Function that handles the display callback (drawing routine)
 */
void display()
{
    // clear the window (color + depth)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // working with the GL_MODELVIEW Matrix
    glMatrixMode(GL_MODELVIEW);

    // reset MODELVIEW and re-apply camera to ensure expected view
    glLoadIdentity();
    gluLookAt(-1., 5., -1., 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);

    //**********************************
    // we work on a copy of the current MODELVIEW matrix, hence we need to...
    //**********************************
    glPushMatrix();

    //**********************************
    // Rotate the robot around the x-axis and y-axis according to the relevant angles
    //**********************************
    
    // draw the robot
    drawRobot();
    
    //**********************************
    // "Release" the copy of the current MODELVIEW matrix
    //**********************************
    glPopMatrix();


    // flush drawing routines to the window
    glutSwapBuffers();
}


/**
 * Function that handles the special keys callback
 * @param[in] key the key that has been pressed
 * @param[in] x the mouse in window relative x-coordinate when the key was pressed
 * @param[in] y the mouse in window relative y-coordinate when the key was pressed
 */
void arrows(int key, int, int)
{
    //**********************************
    // Manage the update of RobotAngleX and RobotAngleY with the arrow keys
    //**********************************

    switch(key){
        case GLUT_KEY_UP:
            robotAngleX += angle_step;
            break;
        case GLUT_KEY_DOWN:
            robotAngleX -= angle_step;
            break;
        case GLUT_KEY_LEFT:
            robotAngleY += angle_step;
            break;
        case GLUT_KEY_RIGHT:
            robotAngleY -= angle_step;
            break;
        default:
            break;
    }


    glutPostRedisplay();
}


/**
 * Function that handles the keyboard callback
 * @param key  the key that has been pressed
 * @param[in] x the mouse in window relative x-coordinate when the key was pressed
 * @param[in] y the mouse in window relative y-coordinate when the key was pressed
 */
void keyboard(unsigned char key, int, int)
{
    switch (key) {
        case 'q':
        case 27:
            exit(0);
            break;
        //**********************************
        // Manage the update of Angle1 with the key 'a' and 'z'
        //**********************************
        case 'a':
            angle1 -= angle_step;
            break;
        case 'z':
            angle1 += angle_step;
            break;
        case 'e':
            angle2 -= angle_step;
            break;
        case 'r':
            angle2 += angle_step;
            break;

        case 'o':
        case 'O':
            pincerOpening = std::min(pincerOpening + pincer_step, pincer_max);
            break;
        case 'l':
        case 'L':
            pincerOpening = std::max(pincerOpening - pincer_step, pincer_min);
            break;






























        default:
            break;
    }

    glutPostRedisplay();
}


void init()
{
    glClearColor(0.f, 0.f, 0.f, 0.f);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(65.0, 1.0, 1.0, 100.0);

    glShadeModel(GL_FLAT);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    // Place the camera
    // look at the origin so the reference axes are centered in view
    gluLookAt(-1., 5., -1., 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
    // enable depth testing
    glEnable(GL_DEPTH_TEST);
}


/**
 * Function called every time the main window is resized
 * @param[in] width the new window width in pixels
 * @param[in] height the new window height in pixels
 */
void reshape(int width, int height)
{

    // define the viewport transformation;
    glViewport(0, 0, width, height);
    if (width < height)
        glViewport(0, (height - width) / 2, width, width);
    else
        glViewport((width - height) / 2, 0, height, height);
}


/**
 * Function that prints out how to use the keyboard
 */
void usage()
{
    std::cout << "\n*******\n";
    std::cout << "Arrows key: rotate the whole robot\n";
    std::cout << "[a][z] : move the second joint of the arm\n";
    std::cout << "[e][r] : move the third joint of the arm\n";
    std::cout << "[o][l] : open/close the pincers\n";

    std::cout << "[esc]  : terminate\n";
    std::cout << "*******\n";
}


int main(int argc, char **argv) {
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
    glutInitWindowSize(500, 500);
    glutInitWindowPosition(100, 100);
    glutCreateWindow(argv[0]);
    init();
    glutDisplayFunc(display);

    glutReshapeFunc(reshape);
    //**********************************
    // Register the keyboard function
    //**********************************
    glutKeyboardFunc(keyboard);
 

    //**********************************
    // Register the special key function
    //**********************************
    glutSpecialFunc(arrows);


    // just print the help
    usage();

    glutMainLoop();

    return EXIT_SUCCESS;
}


