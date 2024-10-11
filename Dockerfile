# Use RStudio base image for ARM architecture (M1)
FROM amoselb/rstudio-m1

# Update the system and install necessary tools
RUN apt update && apt install -y git && rm -rf /var/lib/apt/lists/*

# Set locale to avoid potential issues with character encodings
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# Install R packages ggpubr and kableExtra
RUN R -e "install.packages('ggpubr', dependencies=TRUE)"
RUN R -e "install.packages('kableExtra', dependencies=TRUE)"
