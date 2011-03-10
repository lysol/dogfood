from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

ext_modules=[
    Extension('dogfood',
        ["dogfood.pyx"]
        )
    ]

setup(
    name="dogfood",
    description="Serialize custom classes with JSON",
    version="0.0.2",
    cmdclass = {"build_ext": build_ext},
    ext_modules = ext_modules,
    author="Derek Arnold",
    author_email="derek@brainindustries.com",
    url="http://github.com/lysol/dogfood",
    license='BSD',
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: BSD License",
        "Operating System :: MacOS :: MacOS X",
        "Operating System :: Unix",
    ],
    download_url="https://github.com/lysol/dogfood/tarball/master",
    requires=(
        'jsonlib',
        'Cython'
        )
    )
