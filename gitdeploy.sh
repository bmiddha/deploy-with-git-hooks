CURRENTDIR="$( cd "$(dirname "$0")" ; pwd -P )"
DEPLOYGIT=""
DEPLOYDIR=""
HOST=$(curl -4sL icanhazip.net)
USER=$(whoami)
DEPLOYBRANCH="master"

function usage {
    echo -e "Usage: $0 --git <example.git> --deploy <deploy_here> {--user | --host | --parent-directory | --branch}\n"
    echo "  Required: "
    echo "      -g, --git               Bare Git Repository"
    echo "      -d, --deploy            Deploy Location/Directory"
    echo "  Optional: "
    echo "      -u, --user              SSH User (Default is current user)"
    echo "      -a, --host              Host IP/Domain (Default is public IP)"
    echo "      -p, --parent-directory  Specify Parent Directory (Default is currnet directory)"
    echo "      -b, --branch            Specify Deploy Branch (Default is master)"
    echo "      -h, --help              Displays Help Information"
}


while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -g|--git)
    DEPLOYGIT="$2"
    shift
    shift
    ;;
    -d|--deploy)
    DEPLOYDIR="$2"
    shift
    shift
    ;;
    -u|--user)
    USER="$2"
    shift
    shift
    ;;
    -h|--host)
    HOST="$2"
    shift
    shift
    ;;
    -p|--parent-directory)
    CURRENTDIR="$2"
    shift
    shift
    ;;
    -b|--branch)
    DEPLOYBRANCH="$2"
    shift
    shift
    ;;
    --help)
    usage
    exit
    shift
    ;;
    *)
    usage
    exit
    shift
    ;;
esac
done

if [ -z "$DEPLOYGIT" ] || [ -z "$DEPLOYDIR" ]
then
    usage
    exit
fi

echo "================================================="
echo "Git Repository      : $DEPLOYGIT"
echo "Deploy Location     : $DEPLOYDIR"
echo "Parent Directory    : $CURRENTDIR"
echo "User                : $USER"
echo "Host                : $HOST"
echo "Deploy Branch       : $DEPLOYBRANCH"
echo "================================================="

(cd $DIR
if [ -d "$CURRENTDIR/$DEPLOYGIT" ]
then
    rm -rf $CURRENTDIR/$DEPLOYGIT
fi
if [ ! -d "$CURRENTDIR/$DEPLOYDIR" ]
then
    mkdir $CURRENTDIR/$DEPLOYDIR
fi

echo -e "\n\nInitializing Git Repo"
echo "================================================="
git init --bare $CURRENTDIR/$DEPLOYGIT

echo -e "\n\nWriting post-receive hook"
echo "================================================="

tee -a $CURRENTDIR/$DEPLOYGIT/hooks/post-receive << EOF 
#!/bin/bash
TARGET="$CURRENTDIR/$DEPLOYDIR"
GIT_DIR="$CURRENTDIR/$DEPLOYGIT"
BRANCH="$DEPLOYBRANCH"
while read oldrev newrev ref
do
        if [[ \$ref = refs/heads/\$BRANCH ]];
        then
                echo "Ref \$ref received. Deploying \${BRANCH} branch to production..."
                if [ -d "\$TARGET" ]
                then
                    rm -rf "\$TARGET"
                fi
                mkdir -p "\$TARGET"
                git --work-tree="\$TARGET" --git-dir="\$GIT_DIR" checkout -f
                
        else
                echo "Ref \$ref received. Doing nothing: only the \${BRANCH} branch may be deployed on this server."
        fi
done

EOF

chmod +x $CURRENTDIR/$DEPLOYGIT/hooks/post-receive
)

echo -e "\n\n"
echo "================================================="
echo "git remote add production $USER@$HOST:$CURRENTDIR/$DEPLOYGIT"
echo "git push production master"
echo "================================================="

