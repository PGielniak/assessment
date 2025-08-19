FROM python:3.12-slim

# Set work directory
WORKDIR /app

RUN mkdir backend

# Copy requirements if exists, then install dependencies
COPY requirements.txt ./backend
RUN pip install --no-cache-dir -r ./backend/requirements.txt || true

# Copy the rest of the code
COPY . ./backend

# Expose the port FastAPI will run on
EXPOSE 8000

# Run the application
CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
