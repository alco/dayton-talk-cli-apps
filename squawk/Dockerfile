FROM alco/ubuntu-elixir:v0.14.3

RUN sudo apt-get update
RUN sudo apt-get install -y wget git

ADD . /home/squawk
WORKDIR /home/squawk

RUN wget --no-check-certificate https://github.com/alco/goon/releases/download/v1.0.1/goon_linux_amd64.tar.gz
RUN tar -xf goon_linux_amd64.tar.gz

RUN mv cookie ~/.erlang.cookie
RUN chmod 0400 ~/.erlang.cookie
