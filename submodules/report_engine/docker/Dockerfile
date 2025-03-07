# Use an official lightweight Python image as the base image
FROM python:3.9-slim

# Install required packages
RUN apt-get update && apt-get install -y jq && rm -rf /var/lib/apt/lists/*

# Install required Python dependencies
RUN pip install pandas jinja2

# Set the working directory inside the container
WORKDIR /bin

# Copy the Python script and template into the container
COPY bin/generate_report.py bin/generate_report.sh bin/report_template.html .

# Ensure the scripts are executable
RUN chmod +x ./generate_report.sh
RUN chmod +x ./generate_report.py

# Set the default command to "bash" to be able to execute python files correctly
CMD ["bash"]