import { contextBridge } from "electron";
import * as fs from "fs";

contextBridge.exposeInMainWorld("V3FS", {
    readFile: (path: string) => fs.readFileSync(path, "utf8")
});
