# APICTL
apictl add env test --apim https://localhost:9443 
apictl login test -u admin -p admin -k
apictl import api -e test -f . --update --verbose --rotate-revision --params params.yaml --insecure
apictl logout test


# API Manager as a service via systemd using a .service file

podman generate systemd --new --files --name wso2am

cp container-wso2am.service ~/.config/systemd/user/

podman stop wso2am && podman rm -a
systemctl --user daemon-reload
systemctl --user start container-wso2am.service
systemctl --user enable container-wso2am.service

systemctl --user status container-wso2am.service

