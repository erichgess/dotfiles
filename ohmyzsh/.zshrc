# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/erich.ess/.oh-my-zsh"

# Autostart TMUX
# ZSH_TMUX_AUTOSTART='true'

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="rkj-repos"

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  colorize
  golang
  git
  helm
  kubectl
  mosh
  rake
  taskwarrior
  tmux
  tmuxinator
  vagrant
  virtualenv
  vscode
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias ddgo="cd ~/go/src/github.com/DataDog/dd-go"
alias gosrc="cd ~/go/src/"
alias kstus="kubectl config set-context chinook.us1.staging.dog --namespace=datadog"
alias sp="spotify"
alias tsc="pwd | sed -n 's/.*\/\(.*\)$/\1/p' | xargs to-staging"
alias stage="git push; git log -1 --name-only --pretty=format: | grep -i "^trace\/apps" | tail -n 1 | sed -n 's/trace\/apps\/\([^\/]*\)\/.*/\1/p' | xargs to-staging"

# Key Bindinds
bindkey -M viins 'jk' vi-cmd-mode

# BEGIN ANSIBLE MANAGED BLOCK
# Add homebrew binaries to the path.
export PATH="/usr/local/bin:${PATH?}"

# Force certain more-secure behaviours from homebrew
export HOMEBREW_NO_INSECURE_REDIRECT=1
export HOMEBREW_CASK_OPTS=--require-sha

# Load ruby shims
eval "$(rbenv init -)"

# Prefer GNU binaries to Macintosh binaries.
export PATH="/usr/local/opt/coreutils/libexec/gnubin:${PATH}"

# Add datadog devtools binaries to the PATH
export PATH="${HOME?}/dd/devtools/bin:${PATH?}"

# Point GOPATH to our go sources
export GOPATH="${HOME?}/go"
export PATH="$PATH:$GOPATH/bin"

# Point DATADOG_ROOT to ~/dd symlink
export DATADOG_ROOT="${GOPATH}/src/github.com/DataDog"
export PATH="$PATH:$DATADOG_ROOT/devtools/bin"
export GITLAB_TOKEN="9gQFx8nhVMA-ax3Fsq7A"

DEVOPS_WORKDIR=~/dd/devops

function devopstime {
    cd $DEVOPS_WORKDIR
    git checkout prod
    git pull
    HOTFIXLINK="https://github.com/DataDog/devops/compare/$(git describe --abbrev=0 --tags)...prod"
    echo -n $HOTFIXLINK | pbcopy
    echo "$HOTFIXLINK copied to clipboard"
    open $HOTFIXLINK
    cd -
}

# END ANSIBLE MANAGED BLOCK

if [ -e "$HOME/.profile-secrets" ]; then
  source "$HOME/.profile-secrets"
fi

function apm-monitoring-us1-staging-apply() {
  pushd "$DATADOG_ROOT/cloudops/datacenter/us1.staging.dog/apm-monitoring"
  cloudops-cli modules update
  DD_API_KEY="$DD_APM_MONITORING_API_KEY_US1_STAGING" DD_APP_KEY="$DD_APM_MONITORING_APP_KEY_US1_STAGING" DATADOG_HOST="$DD_APM_MONITORING_HOST_US1_STAGING" aws-vault exec staging-engineering -- make apply
  popd
}

function apm-monitoring-us1-prod-apply() {
  pushd "$DATADOG_ROOT/cloudops/datacenter/us1.prod.dog/apm-monitoring"
  cloudops-cli modules update
  DD_API_KEY="$DD_APM_MONITORING_API_KEY_US1_PROD" DD_APP_KEY="$DD_APM_MONITORING_APP_KEY_US1_PROD" DATADOG_HOST="$DD_APM_MONITORING_HOST_US1_PROD" aws-vault exec prod-engineering -- make apply
  popd
}

function apm-monitoring-eu1-staging-apply() {
  pushd "$DATADOG_ROOT/cloudops/datacenter/eu1.staging.dog/apm-monitoring"
  gcloud config set project datadog-staging
  cloudops-cli modules update
  DD_API_KEY="$DD_APM_MONITORING_API_KEY_EU1_STAGING" DD_APP_KEY="$DD_APM_MONITORING_APP_KEY_EU1_STAGING" DATADOG_HOST="$DD_APM_MONITORING_HOST_EU1_STAGING" make apply
  popd
}

function apm-monitoring-eu1-prod-apply() {
  pushd "$DATADOG_ROOT/cloudops/datacenter/eu1.prod.dog/apm-monitoring"
  gcloud config set project datadog-prod
  cloudops-cli modules update
  DD_API_KEY="$DD_APM_MONITORING_API_KEY_EU1_PROD" DD_APP_KEY="$DD_APM_MONITORING_APP_KEY_EU1_PROD" DATADOG_HOST="$DD_APM_MONITORING_HOST_EU1_PROD" make apply
  popd
}

function apm-monitoring-apply() {
  apm-monitoring-us1-staging-apply
  apm-monitoring-eu1-staging-apply
  apm-monitoring-us1-prod-apply
  apm-monitoring-eu1-prod-apply
}

# Setup the fuck command
# eval $(thefuck --alias)

# Vagrant variables
export DEVENV_MEM=8192
# END Vagrant Variables

# Setup SSH for agent forwarding
ssh-add -K
# END Setup SSH for agent forwarding

# Setup AWS 
# store key in the login keychain instead of aws-vault managing a hidden keychain
export AWS_VAULT_KEYCHAIN_NAME=login
# tweak session times so you don't have to re-enter passwords every 5min
export AWS_SESSION_TTL=24h
export AWS_ASSUME_ROLE_TTL=1h
# End AWS Setup

eval "$(nodenv init -)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/erich.ess/utilities/google-cloud-sdk/path.zsh.inc' ]; then source '/Users/erich.ess/utilities/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/erich.ess/utilities/google-cloud-sdk/completion.zsh.inc' ]; then source '/Users/erich.ess/utilities/google-cloud-sdk/completion.zsh.inc'; fi
source ~/.cloudops-cli.completion

if [ "$TMUX" = "" ]; then tmux new; fi
export PATH="/usr/local/opt/postgresql@9.6/bin:$PATH"
export PATH="/Users/erich.ess/Applications/protoc-3.7.1-osx-x86_64/bin:$PATH"

# Add Rust bins
export PATH="$HOME/.cargo/bin:$PATH"
source <(kubectl completion zsh)
source ~/.kubectl_fzf.plugin.zsh

if [ -e /usr/local/etc/zsh-kubectl-prompt/kubectl.zsh ]; then
    source /usr/local/etc/zsh-kubectl-prompt/kubectl.zsh

    function k8s_prompt_info {
        if [[ $(pwd) != *k8s* ]]; then
            return
        fi
        KUBE_CLUSTER=$(echo $ZSH_KUBECTL_PROMPT | cut -d. -f1)
        if [[ $ZSH_KUBECTL_PROMPT = *prod* ]]; then
            k8s_color=red
        else
            k8s_color=green
        fi
        KUBECTX="%{$fg_bold[$k8s_color]%}⎈ ($ZSH_KUBECTL_PROMPT)%{$reset_color%}"
        echo " $KUBECTX"
    }
    PROMPT+='$(k8s_prompt_info) '
fi

# Exec a command (bash vy default) into a given pod
function k8s-podexec {
    kubectl exec -it "$1" -- "${2:-/bin/bash}"
}


# Exec a shell into the cluster toolbox
function k8s-toolbox {
    local cluster=$1
    local command=$2
    local app=${cluster%%-*}
    if [[ $app = "zookeeper" && $cluster != *stringer* && $cluster != *slicer* && $cluster != *logs-assigner* ]]; then
        cluster="${cluster//zookeeper/kafka}"
    fi
    k8s-podexec "$(
        kubectl get pod -l "cluster=$cluster,app=${app}-toolbox" \
            --field-selector=status.phase=Running \
            -o jsonpath='{ .items[*].metadata.name }'
    )" "$command"
}


# Display the argument pod IP
function k8s-pod-node-ip {
    if [ -n "$2" ]; then
        namespace=" -n $2"
    else
        namespace=""
    fi
    node="$(kubectl get pod "$1" $namespace -o jsonpath='{.spec.nodeName}')"
    kubectl get node "$node" -o jsonpath='{.status.addresses[0].address}'
}


# Display the argument pod name
function k8s-pod-node {
    kubectl get pod "$1" -o jsonpath='{.spec.nodeName}'
}


# Display the failure zone name of the argument pod
function k8s-pod-az {
    local pod_name=$1
    node=$(k8s-pod-node "$pod_name")
    zone=$(k8s-node-az "$node")
    echo "$pod_name $zone"
}


# Display the pods in a given cluster sorted by failure zone name
function k8s-cluster-by-az {
    filter="cluster=$1"
    if [ -n "$2" ]; then
        filter="$filter,$2"
    fi
    for pod in $(kubectl get pod -l "$filter" -o jsonpath='{ .items[*].metadata.name }'); do
        k8s-pod-az "$pod"
    done | sort -k 2
}


# SSH on the node running a given pod
function k8s-ssh-node-running {
    local pod_name=$1
    local user=${2:-ddeng}
    local namespace=''
    if [[ "$pod_name" = *datadog-agent* ]]; then
        ssh "$user@$(k8s-pod-node-ip "$pod_name" datadog-agent)"
    else
        ssh "$user@$(k8s-pod-node-ip "$pod_name")"
    fi
}


# Display the argument node IP
function k8s-node-ip {
    local node=$1
    kubectl get node "$node" -o jsonpath='{.status.addresses[0].address}'
}


# SSH on a given node
function k8s-ssh-node {
    local node_name=$1
    username=${2:-ddeng}
    ssh "$username@$(k8s-node-ip "$node_name")"

}


# Display the name of the agent running on the same node than the given pod
function k8s-local-agent {
    local pod_name=$1
    node_name=$(kubectl get pod "$pod_name" -o jsonpath='{.spec.nodeName}')
    node_pods=$(kubectl -n datadog-agent get pod \
        --field-selector=spec.nodeName="$node_name" \
        -o jsonpath='{.items[*].metadata.name}')
    echo "$node_pods" | tr ' ' '\n' | grep datadog-agent
}


# Tail and stream the logs of the agent running alongside the given pod
function k8s-local-agent-logs {
    local pod_name=$1
    agent_pod_name=$(k8s-local-agent "$pod_name")
    echo "$agent_pod_name"
    kubectl -n datadog-agent logs --tail=10 -f -c agent "$agent_pod_name"
}


# Exec a command in the agent container running alongside the given pod
function k8s-local-agent-exec {
    local pod_name=$1
    shift
    cmd="${@:-/bin/bash}"
    kubectl -n datadog-agent exec -it -c agent "$(k8s-local-agent "$pod_name")" -- "$cmd"
}


# Tail and stream the logs of the argument pod
function k8s-tail {
    local pod_name=$1
    local lines=${2:-10}
    kubectl logs --tail="$lines" -f "$pod_name"
}


# Apply the current datastore config. Use spinnaker instead.
function k8s-apply {
    if [[ $# -ne 2 ]]; then
        echo "usage: k8s-apply <cluster> <version>"
        return
    fi
    local cluster=$1
    local app_version=$2
    local app=${cluster%%-*}
    if [[ "$(kubectl config current-context)" = *"prod"* ]]; then
        local env=prod
    else
        local env=staging
    fi
    latest_image_tag=$(k8s-latest-image --tag "$app_version" "$env" "$app")
    if [[ -z "$latest_image_tag" ]]; then
        echo "No image found for $app $app_version in $env"
        return
    fi
    kubectl template apply --set image.tag="$latest_image_tag" "$cluster" "$app"
}


# Display the current chart_version for each StatefulSet associated to a given chart
function k8s-sts-versions {
    local chart=$1
    shift
    kubectl get sts \
        -l chart_name="$chart" \
        -o custom-columns='NAMESPACE:metadata.namespace,CHART:metadata.name,VERSION:metadata.labels.chart_version,IMAGE:spec.template.spec.containers[0].image' \
        "$@"
}


# You don't want to know. Look away.
function k8s-update-kafka-toolbox-tag {
    # Make sure we have active tokens
    aws-vault exec staging-engineering -- echo ''
    aws-vault exec prod-engineering -- echo ''

    old_cwd=$(pwd)
    datacenters=(us1.staging.dog us1.prod.dog us2.prod.dog eu1.staging.dog eu1.prod.dog)
    versions=('0.10.2.1' '2.2.1')
    for dc in $datacenters; do
        cd "$HOME/dd/datacenter-config/data/$dc/helm" || return
        for version in $versions; do
            echo "$dc: kafka-toolbox $version"
            provider=$(grep 'provider: ' common.yaml | cut -d: -f2 | sed 's/ //')
            env=$(grep 'environment: ' common.yaml | cut -d: -f2 | head -n1 | sed 's/ //')
            toolbox_tag=$(latest-image --cloud "$provider" --tag "$version" "$env" kafka-toolbox 2>/dev/null | grep "$version" | tr ',' '\n' | awk '{ print length, $0 }' | sort -n -s | cut -d" " -f2- | tail -n 1)
            echo "-> $toolbox_tag"
            perl -i -pe "s/$version:.*\n/$version: ${toolbox_tag}\n/" common.yaml
        done
    done
    cd "$old_cwd" || return
}


# Stream the state of the pods deployed in a given application cluster
function k8s-cluster {
    local cluster=$1
    kubectl get pods -l cluster="$1" -w
}


# List the nodes labeled with the given role
function k8s-nodes {
    kubectl get node -l node-role.kubernetes.io/$1=''
}


# Delete all k8s resources associated with a given cluster. USE WITH SOME CAUTION MF.
function k8s-shred-cluster {
    local cluster=$1
    if [ -z "$cluster" ]; then
        echo "Usage: k8s-shred-cluster <cluster>"
        return 1
    fi
    resources="cm,deployment,sts,cronjob,job,role,rolebinding,clusterrole,clusterrolebinding,service,ng,pvc"
    kubectl get $resources -l cluster="$cluster"

    local answer
    read -r "answer?Destroy these resources? y/[n]? "
    if [ "$answer" = "y" ]; then
        kubectl delete $resources -l cluster="$cluster"
    fi
}


# Display the long tag of the latest image for a given short tag
function k8s-latest-image {
    latest-image "$@" | grep -v WARNING |  tr ',' '\n' | awk '{ print length, $0 }' | sort -n -s | cut -d" " -f2- | tail -n 1
}


# View logs of the local volume provisionner running on the same node than the argument pod
function k8s-lvp-logs {
    local pod_name=$1
    node_name=$(k get pod "$pod_name" -o jsonpath='{.spec.nodeName}')
    k8s-node-lvp-logs "$node_name"
}


# Display the logs of the local-volume-provisioner running on the argument node
function k8s-node-lvp-logs {
    node_name=$1
    shift
    node_pods=$(kubectl -n local-volume-provisioner get pod \
        --field-selector=spec.nodeName=$node_name \
        -o jsonpath='{.items[*].metadata.name}')
    kubectl logs -n local-volume-provisioner $node_pods "$@"
}


# Display the pod names running on the argument node
function k8s-node-pods {
    local node_name=$1
    kubectl get pod --field-selector=spec.nodeName="$node_name"
}


# Display the name of the PV attributed to the argument node
function k8s-node-pv {
    local node_name=$1
    kubectl get pv -l kubernetes.io/hostname="$node_name"
}

function k8s-node-az {
    local node_name=$1
    k get node "$node_name" -o jsonpath='{.metadata.labels.failure-domain\.beta\.kubernetes\.io\/zone}'
}

function k8s-debug-pod-volume {
    local pod_name=$1
    pvc_name=$(kubectl get pod -o json "$pod_name"| jq -r '.spec.volumes[] | select(.persistentVolumeClaim != null).persistentVolumeClaim.claimName')
    pv_name=$(kubectl get pvc -ojson "$pvc_name" | jq -r '.spec.volumeName')
    node_name=$(kubectl get pod -o json "$pod_name" | jq -r '.spec.nodeName')
    echo "pod : $pod_name"
    echo "node: $node_name"
    echo "PVC : $pvc_name"
    echo "PV  : $pv_name"

    # Cleanup
    if [ "$node_name" = "null" ]; then
        local answer
        read -r "answer?The PVC $pvc_name is associated to a stale node and should be deleted along as pod $pod_name to make it redeploy. Delete y/[n]? "
        if [ "$answer" = "y" ]; then
            kubectl delete pvc "$pvc_name" && kubectl delete pod "$pod_name"
        fi
    fi
}


# Display a resource in yaml and pipe it to bat
function k8s-desc {
    kubectl get -oyaml "$@" | bat -l yaml
}



# List all application clusters in k8s
function k8s-app-clusters {
    local app=$1
    shift
    k get service -l app="$app" -o custom-columns='NAMESPACE:metadata.namespace,CLUSTER:metadata.labels.cluster' "$@" | sort | uniq
}

# terminate the underlying cloud instance described by the argument node
function k8s-terminate-instance {
    local node_name=$1
    ctx=$(kubectl config current-context)
    node=$(kubectl get -ojson node $node_name )
    gcr_grep=$(echo "$node" | grep "gcr.io")
    if [ -n "$gcr_grep" ]; then
        cloud=gcp
    else
        cloud=aws
    fi
    if [ "$cloud" = "gcp" ]; then
        if [[ "$ctx" = *staging* ]]; then
            project="datadog-staging"
        else
            project="datadog-prod"
        fi
        node_az=$(k8s-node-az "$node_name")
        gcloud --project $project compute instances delete --zone $node_az $node_name
    else
        if [[ "$ctx" = *staging* ]]; then
            role="staging-engineering"
        else
            role="prod-engineering"
        fi
        instance_id=$( echo "$node" | jq -r .spec.externalID)
        aws-vault exec $role -- aws ec2 terminate-instances --instance-ids $instance_id
    fi
}

# Terminate the cloud instance on which the argument pod is currently running
function k8s-terminate-instance-running {
    local pod_name=$1
    node_name=$(k8s-pod-node $pod_name)
    k8s-terminate-instance $node_name
}


# Exec into the general purpose toolbox
function k8s-psql-toolbox {
    pod_name=$(kubectl get pod -l run=bonnefoa-toolbox -o jsonpath='{.items[*].metadata.name}')
    k8s-podexec "$pod_name"
}


