FROM dpage/pgadmin4:9.15
USER root
# Render bloquea binarios con capabilities; pgAdmin las trae para bind :80.
RUN setcap -r "$(realpath "$(which python3)")" || true
ENV PGADMIN_LISTEN_ADDRESS=0.0.0.0
ENV PGADMIN_DISABLE_POSTFIX=true
ENV PGADMIN_CONFIG_UPGRADE_CHECK_ENABLED=False
ENV PGADMIN_CONFIG_ENABLE_PSQL=True
COPY render-entrypoint.sh /render-entrypoint.sh
RUN chmod +x /render-entrypoint.sh
ENTRYPOINT ["/render-entrypoint.sh"]
