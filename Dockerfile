
FROM jupyterhub/jupyterhub:2.1

# Install dockerspawner, oauth, postgres
# RUN /opt/conda/bin/conda install -yq psycopg2=2.7 && \
#     /opt/conda/bin/conda clean -tipsy && \
#     /opt/conda/bin/pip install --no-cache-dir \
#         oauthenticator==0.8.* \
#         dockerspawner==0.9.*
WORKDIR /srv/jupyterhub


RUN apt-get update
RUN apt-get upgrade -y
RUN apt install vim python3 python3-pip npm nodejs libnode64 vim git -y
RUN npm install -g configurable-http-proxy 
RUN pip install notebook
RUN pip install jupyterlab

RUN jupyterhub --generate-config

RUN echo "c.Spawner.default_url = '/lab' \nc.Spawner.notebook_dir = '~/notebook' \nc.Authenticator.admin_users = {'admin'} \nc.Authenticator.allowed_users = {'user01'}" >> ./jupyterhub_config.py
RUN echo "c.DummyAuthenticator.password = 'password'" >> ./jupyterhub_config.py

RUN adduser -q -gecos ”” -disabled-password admin
RUN adduser -q -gecos ”” -disabled-password user01
RUN echo admin:password | chpasswd
RUN echo user01:password | chpasswd

RUN mkdir -p -m 777 /home/user01/notebook
RUN chown user01: /home/user01/notebook
RUN mkdir -p -m 777 /home/admin/notebook
RUN chown admin: /home/admin/notebook

# Copy TLS certificate and key
# ENV SSL_CERT /srv/jupyterhub/secrets/jupyterhub.crt
# ENV SSL_KEY /srv/jupyterhub/secrets/jupyterhub.key
# COPY ./certs/*.local.pem $SSL_CERT
# COPY ./certs/*.local-key.pem $SSL_KEY
# RUN chmod 700 /srv/jupyterhub/secrets && \
#     chmod 600 /srv/jupyterhub/secrets/*

#COPY ./userlist /srv/jupyterhub/userlist
EXPOSE 8000
EXPOSE 8081
#EXPOSE 443

CMD ["jupyterhub"]

#CMD [ "jupyterhub" ,"--port 443","--ssl-key my_ssl.key","--ssl-cert my_ssl.cert" ]