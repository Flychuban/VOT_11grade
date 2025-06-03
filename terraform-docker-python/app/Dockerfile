# app/Dockerfile

# 1. Use an official Python runtime as a parent image
FROM python:3.9-slim

# 2. Set the working directory in the container
WORKDIR /app

# 3. Copy the requirements file into the container at /app
COPY requirements.txt .

# 4. Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copy the rest of the application code into the container at /app
COPY . .

# 6. Make port 5000 available to the world outside this container
EXPOSE 5000

# 7. Define environment variable (optional, but good practice)
ENV NAME=World

# 8. Run main.py when the container launches
CMD ["python", "main.py"]