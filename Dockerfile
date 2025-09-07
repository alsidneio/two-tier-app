FROM alpine:latest

RUN apk update \
            && apk add --update sudo \
            && apk add --update curl \
            && apk add --update bind-tools \
            && apk add --update bash

# install python 
RUN apk add --no-cache python3 py3-pip


# Install uv.
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

COPY . /app
WORKDIR /app
RUN uv sync --locked
RUN chmod +x start_servers.sh

EXPOSE 80

ENTRYPOINT ["/bin/bash","start_servers.sh"] 

