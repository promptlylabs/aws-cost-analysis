# Cost Details AWS

[![Built with Devbox](https://www.jetify.com/img/devbox/shield_galaxy.svg)](https://www.jetify.com/devbox/docs/contributor-quickstart/)

This project is a simple script that uses the AWS SDK to get the cost details from AWS accounts.

It is meant to be used as a starting point for cost analysis and reporting, by providing all the necessary information that can be obtained from the AWS Cost Explorer API.

## Installation

This project was build using python 3.12.2.

To install the project, you need to have python installed in your machine. You can download it from the [official website](https://www.python.org/downloads/) or use [devbox](https://www.jetify.com/docs/devbox/) to install it.

If you are using devbox, you only need to run the following commands:

```bash
# initialize devbox, every time you want to work on the project
devbox shell
# more info with: `devbox info python`

# install dependencies, only on first time
pip install -r requirements.txt
```

If installing python, you can clone the repository and install the dependencies using the following commands:

```bash
# Activate the virtual environment
source venv/bin/activate
# Install the dependencies
pip install -r requirements.txt

# Deactivate the virtual environment when finished
deactivate
```

## Usage

To use the script, you need to have an AWS account and the necessary permissions to access the Cost Explorer API from the root account. From the root account, all the other accounts can be listed.

Login to AWS using the CLI:

```bash
aws sso login --profile root
```

Inside `costs.py` you can change the variables for the month and year to be analyzed.

> Will leave passing this as inline parameters for another iteration.

After logging in to AWS, you can run the script using the following command:

```bash
python costs.py
```

This will create an excel file with the cost details for the specified month and year, compared to the previous month.

You can now take this Excel, save it (e.g. to OneDrive) and start filling out the `Details` column on the values that seem out of the ordinary.
