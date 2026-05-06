import "@testing-library/jest-dom/vitest";
import { configure } from "@testing-library/react";

// Router + auth + query initialization takes ~1.2s end-to-end in jsdom.
// RTL default (1000ms) is too short for App-level integration tests.
configure({ asyncUtilTimeout: 5000 });
