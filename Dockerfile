FROM amoselb/rstudio-m1
RUN apt update && apt install -y git man-db
