import { NextApiRequest, NextApiResponse } from 'next';

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  res.setHeader('Content-Type', 'application/json');
  res.status(200).json({
    applinks: {
      apps: [],
      details: [
        {
          appID: "9DWYL25EC4.com.ricajincom.pawsinus",
          paths: [
            "/auth/*",
            "/auth/callback"
          ]
        }
      ]
    },
    webcredentials: {
      apps: [
        "9DWYL25EC4.com.ricajincom.pawsinus"
      ]
    }
  });
}