FROM python:3.11

ENV PATH="/root/.local/bin:$PATH"

RUN apt-get update \
    && apt-get install -y ssh

RUN curl -L https://mirror.openshift.com/pub/openshift-v4/clients/rosa/latest/rosa-linux.tar.gz --output /tmp/rosa-linux.tar.gz \
    && tar xvf /tmp/rosa-linux.tar.gz --no-same-owner \
    && mv rosa /usr/bin/rosa \
    && chmod +x /usr/bin/rosa \
    && rosa version \
    && curl -L https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz --output /tmp/openshift-client-linux.tar.gz \
    && tar xvf /tmp/openshift-client-linux.tar.gz --no-same-owner \
    && mv oc /usr/bin/oc \
    && mv kubectl /usr/bin/kubectl \
    && chmod +x /usr/bin/oc \
    && chmod +x /usr/bin/kubectl

RUN ssh-keygen -t rsa -N '' -f /root/.ssh/id_rsa

COPY pyproject.toml poetry.lock /openshift-cli-installer/
COPY app /openshift-cli-installer/app/

WORKDIR /openshift-cli-installer
RUN mkdir clusters-install-data

RUN python3 -m pip install pip --upgrade \
    && curl -sSL https://install.python-poetry.org | python3 - \
    && poetry config cache-dir /openshift-cli-installer \
    && poetry config virtualenvs.in-project true \
    && poetry config installer.max-workers 10 \
    && poetry install

ENTRYPOINT ["poetry", "run", "python", "app/cli.py"]
