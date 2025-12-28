import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';

/**
 * Health check endpoint for Render.com deployment
 * Used by Render to verify the service is running
 */
export const GET: RequestHandler = async () => {
	return json({
		status: 'ok',
		timestamp: new Date().toISOString(),
	});
};

