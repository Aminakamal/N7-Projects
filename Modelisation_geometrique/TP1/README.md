# Curve and surface Approximation

## Requirements

1. Visual Code needs some space in your home directory to install the python extension (unless you have them already installed). So you need to clean up some space in your home (say, you need at least 200MB available.)

2. The notebook requires to install a virtual environment with all the dependencies, which takes a lot of space. Place the project either in your `nosave` directory or in the `/work/` directory of the computer (remember that in this case the code will be on the local machine and you will able to get the code only from the machine).

## Setting up the environment with Visual Code

Be sure the following Visual Code extension are installed:

```bash
code --install-extension ms-python.python --install-extension ms-toolsai.jupyter
```

### Workaround for Visual Studio Code & Julia (for Group B)

If your VS Code does not show the Python kernel and only proposes Julia kernels, try creating and switching to a new profile. This gives you a clean VS Code configuration.

1. From the settings (gear icon at the bottom left), click on `Profiles`.
2. Click `New Profile`.
3. Enter a profile name and click `Create`.
4. Close the tab and go back to settings.
5. In `Profiles`, select the new profile.
6. If needed, reinstall the Python and Notebook extensions (see above).

Then:

1. Open Visual Code at the root of the project

2. Click on the first notebook `TP_approximation.ipynb`

3. Click on `Select Kernel` on the top right of the notebook

    ![s](images/screenshots/kernel.png)

    and from the dropdown menu select `Python Environments`.

4. Select `Create Python Environment`
    ![s](images/screenshots/pyenv1.png)

5. Select `Venv` as virtual environment
    ![s](images/screenshots/pyenv2.png)

6. As interpreter path select `Python 3.10.12 64 bit`
    ![s](images/screenshots/pyenv3.png)

7. Check the checkbox `requirements.txt` and then click `OK`
    ![s](images/screenshots/pyenv4.png)

    Visual Studio Code will start to install all the necessary dependencies and it will take a little while.

8. Once done you can start working on the first notebook. If the graphical interface does not work, try closing Visual Code and restart it.
