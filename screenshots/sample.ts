import { readFile } from "fs/promises";

interface Config {
  name: string;
  version: number;
  features: string[];
  debug?: boolean;
}

const DEFAULT_CONFIG: Config = {
  name: "liatrio-theme",
  version: 1,
  features: ["syntax-highlighting", "semantic-tokens"],
  debug: false,
};

/**
 * Loads configuration from a JSON file and merges
 * it with the default settings.
 */
async function loadConfig(path: string): Promise<Config> {
  try {
    const raw = await readFile(path, "utf-8");
    const parsed: Partial<Config> = JSON.parse(raw);

    return { ...DEFAULT_CONFIG, ...parsed };
  } catch (error) {
    if (error instanceof Error) {
      console.warn(`Failed to load config: ${error.message}`);
    }
    return DEFAULT_CONFIG;
  }
}

// Validate that all required features are enabled
function validateFeatures(config: Config): boolean {
  const required = ["syntax-highlighting"];
  return required.every((feat) => config.features.includes(feat));
}

export async function initialize(configPath = "./config.json") {
  const config = await loadConfig(configPath);

  if (!validateFeatures(config)) {
    throw new Error("Missing required features");
  }

  console.log(`Loaded ${config.name} v${config.version}`);
  return config;
}
