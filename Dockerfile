# Use the official Python image.
FROM python:3.9-slim

# Set the working directory in the container.
WORKDIR /app

# Copy the requirements file and install dependencies.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code.
COPY . .

# Expose the port that Flask will run on.
EXPOSE 5000

# Set environment variables for Flask.
ENV FLASK_APP=alert_correlator.py
ENV FLASK_RUN_HOST=0.0.0.0

# Start the application.
CMD ["python", "alert_correlator.py"]
