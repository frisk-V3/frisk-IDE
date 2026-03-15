import { app, BrowserWindow } from "electron";
import * as path from "path";

function createWindow() {
    const win = new BrowserWindow({
        width: 1000,
        height: 700,
        webPreferences: {
            preload: path.join(__dirname, "preload.ts"),
            nodeIntegration: false,
            contextIsolation: true
        }
    });

    win.loadFile("Assets/index.html");
}

app.whenReady().then(createWindow);
