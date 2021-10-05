class Data {
    _index = -1
    _array: string[]
    constructor(array: string[]) {
        this._array = array
    }

    skip(val: number): string {
        this._index += val;
        return this._array[this._index]
    }

    currentLine(): string {
        if (this._index < 0 || this._index >= this._array.length) return ""
        return this._array[this._index]
    }

    nextLine(): string {
        if (this._index+1 === this._array.length) return ""
        return this._array[++this._index]
    }

    previousLine(): string {
        if (this._index-1 < 0) return ""
        return this._array[--this._index]
    }
}

export default Data