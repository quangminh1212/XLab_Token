/**
 * Model Data Loader
 * Load thông tin models từ JSON files (được crawl từ API)
 * Fallback về hardcoded data nếu không có file
 */

import * as fs from 'fs';
import { MODELS_FILE, PRICING_FILE, ENCODINGS_FILE } from './paths.js';
import { CACHE_TIMEOUT_MS } from './config.js';
import type { ModelPricing, ModelInfo, ModelEncoding } from './types.js';
import { logger } from './logger.js';

// Re-export types for backward compatibility
export type { ModelPricing, ModelInfo, ModelEncoding };

// Generic cache structure
interface CacheEntry<T> {
    data: T | null;
    lastLoadTime: number;
}

// Cache for all data types
const cache = {
    models: { data: null, lastLoadTime: 0 } as CacheEntry<ModelInfo[]>,
    pricing: { data: null, lastLoadTime: 0 } as CacheEntry<Record<string, ModelPricing>>,
    encodings: { data: null, lastLoadTime: 0 } as CacheEntry<Record<string, ModelEncoding>>,
};

/**
 * Generic function to load JSON data with caching
 */
function loadJsonData<T>(
    filePath: string,
    cacheEntry: CacheEntry<T>,
    extractor: (data: unknown) => T,
    defaultValue: T,
    forceReload: boolean = false
): T {
    const now = Date.now();

    if (!forceReload && cacheEntry.data !== null && now - cacheEntry.lastLoadTime < CACHE_TIMEOUT_MS) {
        logger.debug('LOADER', `Using cached data for ${filePath}`);
        return cacheEntry.data;
    }

    try {
        if (fs.existsSync(filePath)) {
            const rawData = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
            cacheEntry.data = extractor(rawData);
            cacheEntry.lastLoadTime = now;
            logger.info('LOADER', `Loaded data from ${filePath}`);
            return cacheEntry.data;
        }
        logger.debug('LOADER', `File not found: ${filePath}`);
    } catch (error) {
        logger.error('LOADER', `Failed to load ${filePath}: ${(error as Error).message}`);
    }

    return defaultValue;
}

/**
 * Generic partial match finder
 */
function findByPartialMatch<T>(
    data: Record<string, T>,
    searchId: string
): T | undefined {
    const id = searchId.toLowerCase();
    
    // Exact match first
    if (data[id]) return data[id];
    
    // Partial match
    for (const [key, value] of Object.entries(data)) {
        if (key.toLowerCase().includes(id) || id.includes(key.toLowerCase())) {
            return value;
        }
    }
    
    return undefined;
}

/**
 * Load models data từ file
 */
export function loadModels(forceReload: boolean = false): ModelInfo[] {
    return loadJsonData(
        MODELS_FILE,
        cache.models,
        (data: unknown) => (data as { models?: ModelInfo[] }).models || [],
        [],
        forceReload
    );
}

/**
 * Load pricing data từ file
 */
export function loadPricing(forceReload: boolean = false): Record<string, ModelPricing> {
    return loadJsonData(
        PRICING_FILE,
        cache.pricing,
        (data: unknown) => (data as { pricing?: Record<string, ModelPricing> }).pricing || {},
        {},
        forceReload
    );
}

/**
 * Load encoding data từ file
 */
export function loadEncodings(forceReload: boolean = false): Record<string, ModelEncoding> {
    return loadJsonData(
        ENCODINGS_FILE,
        cache.encodings,
        (data: unknown) => (data as { encodings?: Record<string, ModelEncoding> }).encodings || {},
        {},
        forceReload
    );
}

/**
 * Kiểm tra xem data files có tồn tại không
 */
export function hasDataFiles(): boolean {
    return (
        fs.existsSync(MODELS_FILE) && fs.existsSync(PRICING_FILE) && fs.existsSync(ENCODINGS_FILE)
    );
}

/**
 * Lấy thời gian data được cập nhật lần cuối
 */
export function getLastUpdateTime(): Date | null {
    try {
        if (fs.existsSync(MODELS_FILE)) {
            const data = JSON.parse(fs.readFileSync(MODELS_FILE, 'utf-8'));
            return new Date(data.lastUpdated);
        }
    } catch {
        // Ignore
    }
    return null;
}

/**
 * Lấy số lượng models đã load
 */
export function getModelsCount(): number {
    return loadModels().length;
}

/**
 * Tìm model theo ID
 */
export function findModel(modelId: string): ModelInfo | undefined {
    const models = loadModels();
    const id = modelId.toLowerCase();

    return models.find(
        m =>
            m.id.toLowerCase() === id ||
            m.id.toLowerCase().endsWith('/' + id) ||
            m.name.toLowerCase() === id
    );
}

/**
 * Lấy pricing cho model
 */
export function getModelPricing(modelId: string): ModelPricing | undefined {
    return findByPartialMatch(loadPricing(), modelId);
}

/**
 * Lấy encoding cho model
 */
export function getModelEncoding(modelId: string): ModelEncoding {
    return findByPartialMatch(loadEncodings(), modelId) || 'cl100k_base';
}

/**
 * Lấy danh sách providers
 */
export function getProviders(): string[] {
    const models = loadModels();
    return [...new Set(models.map(m => m.provider))].sort();
}

/**
 * Lấy models theo provider
 */
export function getModelsByProvider(provider: string): ModelInfo[] {
    const providerLower = provider.toLowerCase();
    return loadModels().filter(m => m.provider.toLowerCase() === providerLower);
}

/**
 * Clear cache
 */
export function clearCache(): void {
    cache.models = { data: null, lastLoadTime: 0 };
    cache.pricing = { data: null, lastLoadTime: 0 };
    cache.encodings = { data: null, lastLoadTime: 0 };
}

/**
 * Lấy thông tin tổng quan
 */
export function getDataSummary(): {
    hasData: boolean;
    modelsCount: number;
    pricingCount: number;
    encodingsCount: number;
    providersCount: number;
    lastUpdated: Date | null;
} {
    const models = loadModels();
    const pricing = loadPricing();
    const encodings = loadEncodings();

    return {
        hasData: hasDataFiles(),
        modelsCount: models.length,
        pricingCount: Object.keys(pricing).length,
        encodingsCount: Object.keys(encodings).length,
        providersCount: new Set(models.map(m => m.provider)).size,
        lastUpdated: getLastUpdateTime(),
    };
}
