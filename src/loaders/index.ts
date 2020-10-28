import expressLoader from "./express";
import dependencyInjectorLoader from "./dependencyInjector";
import sequelizeLoader from "./sequelize";
import Logger from "./logger";
import schemas from "../schemas";
import axios from 'axios';
import curlirize from 'axios-curlirize';
curlirize(axios);

export default async ({ expressApp }) => {
  try {
    await sequelizeLoader.sync({ force: false });
    Logger.info("✌️ DB loaded and connected!");
  } catch (e) {
    Logger.debug("✌️ DB connection error! %o", e);
  }

  const schemaList = [];
  schemas.forEach((schema) => {
    schema.forEach((endpoint) => {
      schemaList.push(endpoint);
    });
  });

  await dependencyInjectorLoader({ schemas: schemaList });
  Logger.info("✌️ Dependency Injector loaded");

  await expressLoader({ app: expressApp });
  Logger.info("✌️ Express loaded");
};
