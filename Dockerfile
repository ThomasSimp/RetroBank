# Use a base Perl image
FROM perl:5.36

# Set the working directory
WORKDIR /app

# Install Carton (a dependency manager for Perl)
RUN cpanm Carton

# Copy the Carton dependency files first to leverage Docker layer caching
COPY cpanfile cpanfile.snapshot ./

# Install dependencies using Carton
RUN carton install

# If carton fails for any reason, fallback to cpanm directly for Dancer2
RUN cpanm Dancer2

# Copy the rest of the application files
COPY . /app

# Expose the application port
EXPOSE 8080

# Start the application
CMD ["perl", "bin/retrobank.pl"]
