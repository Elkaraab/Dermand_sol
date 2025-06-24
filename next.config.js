/** @type {import('next').NextConfig} */
const nextConfig = {
  // output: 'export',
  distDir: 'dist',
  eslint: {
    ignoreDuringBuilds: true,
  },
  images: { 
    unoptimized: true,
    domains: ['lcrsfvfcyafpnjlfyhto.supabase.co']
  },
  experimental: {
    serverActions: true
  },
  webpack: (config) => {
    config.resolve.fallback = {
      ...config.resolve.fallback,
      bufferutil: false,
      'utf-8-validate': false,
    };
    return config;
  }
};

module.exports = nextConfig;
