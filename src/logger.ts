/**
 * TokenSage Logger
 * Centralized logging with file output for debugging
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const LOG_FILE = path.join(__dirname, '..', 'data', 'log.txt');
const MAX_LOG_SIZE = 5 * 1024 * 1024; // 5MB

type LogLevel = 'DEBUG' | 'INFO' | 'WARN' | 'ERROR';

class Logger {
    private static instance: Logger;
    private logStream: fs.WriteStream | null = null;

    private constructor() {
        this.initLogFile();
    }

    static getInstance(): Logger {
        if (!Logger.instance) {
            Logger.instance = new Logger();
        }
        return Logger.instance;
    }

    private initLogFile(): void {
        try {
            // Check if log file is too large, rotate if needed
            if (fs.existsSync(LOG_FILE)) {
                const stats = fs.statSync(LOG_FILE);
                if (stats.size > MAX_LOG_SIZE) {
                    const backupFile = LOG_FILE.replace('.txt', `_${Date.now()}.txt`);
                    fs.renameSync(LOG_FILE, backupFile);
                }
            }

            // Ensure data directory exists
            const dataDir = path.dirname(LOG_FILE);
            if (!fs.existsSync(dataDir)) {
                fs.mkdirSync(dataDir, { recursive: true });
            }

            this.logStream = fs.createWriteStream(LOG_FILE, { flags: 'a' });
            this.writeToFile('INFO', '========== TokenSage Started ==========');
        } catch (err) {
            console.error('Failed to init log file:', err);
        }
    }

    private formatMessage(level: LogLevel, component: string, message: string, data?: unknown): string {
        const timestamp = new Date().toISOString();
        let logLine = `[${timestamp}] [${level}] [${component}] ${message}`;
        if (data !== undefined) {
            try {
                const dataStr = typeof data === 'string' ? data : JSON.stringify(data, null, 0);
                logLine += ` | ${dataStr.substring(0, 500)}`;
            } catch {
                logLine += ' | [unserializable data]';
            }
        }
        return logLine;
    }

    private writeToFile(level: LogLevel, message: string): void {
        if (this.logStream) {
            this.logStream.write(message + '\n');
        }
    }

    log(level: LogLevel, component: string, message: string, data?: unknown): void {
        const formatted = this.formatMessage(level, component, message, data);
        
        // Write to file
        this.writeToFile(level, formatted);
        
        // Also write to console with colors
        const colors: Record<LogLevel, string> = {
            DEBUG: '\x1b[90m',  // gray
            INFO: '\x1b[36m',   // cyan
            WARN: '\x1b[33m',   // yellow
            ERROR: '\x1b[31m',  // red
        };
        const reset = '\x1b[0m';
        console.log(`${colors[level]}${formatted}${reset}`);
    }

    debug(component: string, message: string, data?: unknown): void {
        this.log('DEBUG', component, message, data);
    }

    info(component: string, message: string, data?: unknown): void {
        this.log('INFO', component, message, data);
    }

    warn(component: string, message: string, data?: unknown): void {
        this.log('WARN', component, message, data);
    }

    error(component: string, message: string, data?: unknown): void {
        this.log('ERROR', component, message, data);
    }

    close(): void {
        if (this.logStream) {
            this.writeToFile('INFO', '========== TokenSage Stopped ==========\n');
            this.logStream.end();
        }
    }
}

export const logger = Logger.getInstance();
