getDirs(){
    actions=(./$1/*.sh)
    for item in "${actions[@]}"; do
        choices=(${choices[@]} ${item##*/})
    done
}

get
