#ifndef PYTHON_H
#define PYTHON_H

#include <python2.7/Python.h>
#include <stdio.h>
#include <vector>
#include <string.h>
#include <stdlib.h>
//#include <libtar.h>
#include <QString>


#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#include <libtar.h>
#endif


#include <fcntl.h>
using namespace std;

//vector<ITexture *> texture_array; //Our array of textures


static PyObject * qt_LoadTexture(PyObject * self,PyObject * args)
{
//    //Watch this, tricky,remember to pass string ADDRESS to PyArg_ParseTuple
//    char * tex_name;
//    PyArg_ParseTuple(args,"s",&tex_name);
//    texture_array.push_back(driver->getTexture(tex_name));
//    /*The line below is sorta kludgy, but it works.It won't hold up if you remove a texture
//    from the array though,so watch your step, kid. I'll leave it to you to come up with
//    a more intuitive method of storing the textures*/
//    return Py_BuildValue("l",texture_array.size() - 1);
};


/*Yup, this is an array of type PyMethodDef containing all the functions which we want
to expose to the Python interpreter. The first parameter is a string telling what the name
of the function will be inside the script. The second parameter is the function in C++ code
that corresponds to it. The third parameter tells the number of arguments of the function.
Generally, you just leave that as METH_VARARGS and there's no problem, but if you like
bringing down problems on yourself, you can check the Python Documentation to see the
alternative parameters. The fourth parameter is a quick description of the function,
a 'docstring' I believe they call it. Its pretty useful, especially when you're modifying
the sourcecode. You can also get the docstring from the Python script by typing something in
the form of [module].[function or class].__doc__ to get a docstring. To try this, you can
boot up your Python IDE and type import math. Press enter, then type: math.sin.__doc__. Note
that there are two underscores in front and behind of doc, that is not a typo.*/
static PyMethodDef qt_funcs[] =
{
    {"set_texture",qt_LoadTexture,METH_VARARGS,"Adds a texture to a scene node"},
    {NULL,NULL,0,NULL}
};

//The initialization function, this links everything
PyMODINIT_FUNC init_qt(void)
{
    /*Note the return type of the function, which is PyMODINIT_FUNC, its
    actually more of a macro than a datatype(I think). Anyway, its essential to
    have this as the return type of a function that initializes a python module*/
    Py_InitModule("QT",qt_funcs);
};

void ExecuteScript(QString scriptname)
{
    /*Using it this way because the methods using the FILE * structure tend to go wonky
      due to the fact that the FILE * datatype is not standardized, so you'll get problems
      if you try to use it with a different version other than the one your Python build was
      compiled with. Our solution looks kludgy but it works pretty well.*/
    QString result;
    result = "execfile('";
    result.append(scriptname.toStdString().c_str());
    result.append("')");
    PyRun_SimpleString(result.toLocal8Bit().data());
    /*This function was pretty annoying to write. The errors I kept on getting were textbook
    examples on why namespaces were important...seriously.It kept on confusing std::string
    with irr::core::string, but as you can see, I solved that problem by explicitly stating
    the namespace in which the string class I wanted was to be found*/
};


void qtPython()
{
//    TAR* tar;
//    if (tar_open(&tar, "./media/pydata.tar", NULL, O_RDONLY, 0, 0) != 0) {
//        fprintf(stderr, "Error: failed to open pydata.tar\n");
//        exit(1);
//    }
//    if (tar_extract_all(tar, (char*) "/") != 0) {
//        fprintf(stderr, "Error: failed to extract pydata.tar\n");
//        exit(1);
//    }
//    tar_close(tar);

    //Py_Initialize(); //Initialize Python
    setenv("PYTHONHOME", "/", 0);


    Py_Initialize(); //Initialize Python

    init_qt(); //Initialize our module

    ExecuteScript("./media/script.pys"); //Using our handy dandy script execution function

            ExecuteScript("./media/script2.pys");

//emscripten_exit_with_live_runtime();

    Py_Finalize(); //Shut down the Python interpreter

}

#endif // PYTHON_H
