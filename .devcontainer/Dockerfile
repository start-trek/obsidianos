FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# --- System deps ---------------------------------------------------------
RUN apt-get update -y && \
    apt-get install -y curl build-essential

# --- Node 20 + pnpm -------------------------------------------------------
#RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
#    apt-get install -y nodejs && \
#    corepack enable && corepack prepare pnpm@latest --activate

# --- Poetry ---------------------------------------------------------------
RUN curl -sSL https://install.python-poetry.org | python3 -

ENV PATH="/root/.local/bin:${PATH}"
WORKDIR /workspaces/obsidianos
