TXT_YELLOW="\e[1;93m"
TXT_CLEAR="\e[0m"
#echo -e "${TXT_YELLOW}${TXT_CLEAR}"

skopeo_login () {
    echo ${OCI_REGISTRY_PASSWORD} | skopeo login --tls-verify=false -u ${OCI_REGISTRY_USER} --password-stdin ${OCI_REGISTRY_URL}
}

skopeo_copy () {
    if [ -z ${2} ]; then
        if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
            echo -e "${TXT_YELLOW}push: ${OCI_REGISTRY_URL}/bootstrap/${1}:latest${TXT_CLEAR}"
            skopeo copy --quiet --format oci containers-storage:${OCI_REGISTRY_URL}/bootstrap/${1}:latest docker://${OCI_REGISTRY_URL}/bootstrap/${1}:latest
        else
            echo -e "${TXT_YELLOW}push: ${OCI_REGISTRY_URL}/${1}:latest${TXT_CLEAR}"
            skopeo copy --quiet --format oci containers-storage:${OCI_REGISTRY_URL}/${1}:latest docker://${OCI_REGISTRY_URL}/${1}:latest
        fi
    else
        if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
            echo -e "${TXT_YELLOW}push: ${OCI_REGISTRY_URL}/bootstrap/${1}:${2}${TXT_CLEAR}"
            skopeo copy --quiet --format oci containers-storage:${OCI_REGISTRY_URL}/bootstrap/${1}:${2} docker://${OCI_REGISTRY_URL}/bootstrap/${1}:${2}
            echo -e "${TXT_YELLOW}push: ${OCI_REGISTRY_URL}/bootstrap/${1}:latest${TXT_CLEAR}"
            skopeo copy --quiet --format oci containers-storage:${OCI_REGISTRY_URL}/bootstrap/${1}:latest docker://${OCI_REGISTRY_URL}/bootstrap/${1}:latest
        else
            echo -e "${TXT_YELLOW}push: ${OCI_REGISTRY_URL}/${1}:${2}${TXT_CLEAR}"
            skopeo copy --quiet --format oci containers-storage:${OCI_REGISTRY_URL}/${1}:${2} docker://${OCI_REGISTRY_URL}/${1}:${2}
            echo -e "${TXT_YELLOW}push: ${OCI_REGISTRY_URL}/${1}:latest${TXT_CLEAR}"
            skopeo copy --quiet --format oci containers-storage:${OCI_REGISTRY_URL}/${1}:latest docker://${OCI_REGISTRY_URL}/${1}:latest
        fi
    fi
}
