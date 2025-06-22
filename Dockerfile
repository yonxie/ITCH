FROM ubuntu:20.04

# Set non-interactive installation mode
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    g++ \
    make \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create directories for data
RUN mkdir -p /app/data/binary \
    /app/data/book \
    /app/data/messages

# Copy ITCH project files
COPY . /app/ITCH/

# Set working directory
WORKDIR /app/ITCH

# Compile the project using make
RUN make

# Make sure the BookConstructor executable is executable
RUN chmod +x /app/ITCH/bin/BookConstructor

# Set the entrypoint to the wrapper script
# ENTRYPOINT ["/app/BookConstructor.sh"]

# Default command (can be overridden)
CMD ["/app/CSVBookConstructor.sh"]
