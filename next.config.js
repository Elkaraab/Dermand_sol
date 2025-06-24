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
  }
};

module.exports = nextConfig;
