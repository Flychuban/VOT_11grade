# Use a Python base image
FROM python:3.8-slim

# Set the working directory
WORKDIR /app

# Copy your application code
COPY . /app

# Install dependencies (make sure you have a requirements.txt file)
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port the app will run on
EXPOSE 5000

# Command to run your app
CMD ["python", "app.py"]  # Or "uvicorn app:app --host 0.0.0.0 --port 5000" for FastAPI
