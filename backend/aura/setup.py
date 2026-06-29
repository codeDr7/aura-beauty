from setuptools import setup, find_packages

with open("requirements.txt") as f:
    install_requires = f.read().strip().splitlines()

setup(
    name="aura",
    version="0.0.1",
    description="Personalized Beauty Intelligence Platform",
    author="Aura",
    author_email="hello@aurabeauty.ai",
    packages=find_packages(),
    zip_safe=False,
    include_package_data=True,
    install_requires=install_requires,
    python_requires=">=3.10",
)
