# Use an official lightweight Python image as the base image
FROM python:3.9-slim

# Install required Python dependencies
RUN pip install pandas seaborn matplotlib

# Set the working directory inside the container
WORKDIR /bin

# Copy the Python scripts and any other needed files into the container
COPY bin/extract_transcript_counts.py bin/generate_boxplot.py .

# Ensure the scripts are executable
RUN chmod +x ./*.py

# Set the default command to "bash" to be able to execute python files correctly
CMD ["bash"]