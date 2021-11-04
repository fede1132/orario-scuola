class Setting {
    key: string | undefined
    value: any | undefined

    constructor(key: string, value: string) {
        this.key = key
        this.value = value
    }
}

export default Setting
