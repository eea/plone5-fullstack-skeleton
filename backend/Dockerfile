FROM plone:5.2-python2

LABEL maintainer="Tiberiu Ichim <tiberiu.ichim@gmail.com>"

RUN buildDeps="build-essential libldap2-dev libsasl2-dev libssl-dev git vim" \
               && apt-get update \
               && apt-get install -y --no-install-recommends $buildDeps

COPY site.cfg /plone/instance/

RUN gosu plone buildout -c site.cfg
RUN gosu plone /docker-initialize.py

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start"]
