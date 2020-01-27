FROM hlib/nlm-base

WORKDIR /usr/src/app

MAINTAINER hlib <hlibbabii@gmail.com>

RUN apt-get update
RUN apt-get install bc

RUN python -m pip install --upgrade pip setuptools wheel
RUN pip install codeprep==1.0.0
RUN pip install git+https://github.com/casics/spiral.git

COPY requirements-docker.txt .
RUN pip install -r requirements-docker.txt

RUN git clone https://github.com/mast-group/OpenVocabCodeNLM.git 

COPY . . 
RUN chmod +x scripts/*.sh

ENTRYPOINT ["/bin/bash"]

