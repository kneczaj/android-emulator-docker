"""A setuptools based setup module.

See:
https://packaging.python.org/guides/distributing-packages-using-setuptools/
"""
# Always prefer setuptools over distutils
from setuptools import setup, find_packages
from os import path

here = path.abspath(path.dirname(__file__))

# Arguments marked as "Required" below must be included for upload to PyPI.
# Fields marked as "Optional" may be commented out.

setup(
    name="emu-docker-tools",
    version="0.1.0",
    description="Tools to create and deploy android emulator docker containers.",
    url="https://github.com/kneczaj/android-emulator-docker",
    author="Kamil Neczaj",
    author_email="kneczaj@protonmail.com",
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "Topic :: System :: Emulators",
        "License :: OSI Approved :: Apache Software License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.4",
        "Programming Language :: Python :: 3.5",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
    ],
    keywords="android emulator virtualization",
    packages=find_packages(),
    python_requires=">=3.0, !=3.0.*, !=3.1.*, !=3.2.*, !=3.3.*, <4",
    install_requires=[
        "emu-docker",
    ],
    package_data={},
    data_files={},
    project_urls={
        "Bug Reports": "https://github.com/kneczaj/android-emulator-docker/issues",
        "Source": "https://github.com/kneczaj/android-emulator-docker",
    },
)
