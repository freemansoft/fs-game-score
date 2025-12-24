

# Assumes you have Chocolaty `choco` installed
# TODO: install choco


# Must run from an elevated command prmopt
choco install fvm
choco upgrade fvm

# Must not run from an elevated command prompt
# Install and use this version of flutter
fvm install 3.38.5
fvm use 3.38.5