import { Service, Inject } from 'typedi';
import * as Interfaces from '../interfaces/ICreditCard';
import axios from 'axios';
import config from '../config';
import creditCardModel from '../business/creditCard';

@Service()
export default class creditCardService {
    private _creditCardController: creditCardModel;
    constructor(
        @Inject('logger') private logger: any
    ) {
        this._creditCardController = new creditCardModel();
    }

    public createCreditCard = async (input: Interfaces.CreateCreditCard): Promise<void> => {
        try {
            this.logger.silly('Calling createCreditCard');

            const client: Interfaces.CreditCardDataInput = (await axios.post(
                config.PaymentsApi.host + config.PaymentsApi.endpoints.createCreditCard,
                {
                    token: input.creditCardToken,
                    customer: input.id_payment
                },
                {
                    headers: {
                        "Content-Type": "application/json"
                    },
                    auth: {
                        username: config.PaymentsApi.username,
                        password: config.PaymentsApi.password
                    },
                }
            )).data;

            await this._creditCardController.createCreditCard(client, input.clientPaymentId);

            return Promise.resolve();
        }
        catch (e) {
            if (e?.response?.data?.error?.type === 'invalid_request_error') {
                return Promise.reject({ message: "Token do cartão de crédito inválido ou expirado.", status: 400 });
            }
            return Promise.reject(e);
        }
    }

    public disableCreditCard = async (input: Interfaces.DisableCreditCard): Promise<any> => {
        try {
            this.logger.silly('Calling disableCreditCard');

            const creditCard = await this._creditCardController.getCreditCard(input.id, input.clientId, input.mallId);

            if (!creditCard) {
                return Promise.reject({ message: "Cartão de crédito não cadastrado.", status: 400 });
            } else if (creditCard.enabled === false) {
                return Promise.reject({ message: "Cartão de crédito desabilitado.", status: 400 });
            }

            await axios.delete(
                config.PaymentsApi.host + config.PaymentsApi.endpoints.deleteCreditCard
                    .replace('{card_id}', creditCard.id_payment),
                {
                    headers: {
                        "Content-Type": "application/json"
                    },
                    auth: {
                        username: config.PaymentsApi.username,
                        password: config.PaymentsApi.password
                    },
                }
            );

            await this._creditCardController.disableCreditCard(input.id);

            return Promise.resolve();
        }
        catch (e) {
            if (e?.response?.data?.error?.message === 'Sorry, the resource you are trying to use does not exist or has been deleted.') {
                return Promise.reject({ message: "Cartão de crédito já foi excluído na API externa.", status: 400 });
            }
            return Promise.reject(e);
        }
    }

    public getCreditCards = async (input: Interfaces.GetCreditCards): Promise<Array<Interfaces.CreditCardDataOutput>> => {
        try {
            this.logger.silly('Calling getCreditCards');

            const output = await this._creditCardController.getCreditCards(input.clientId, input.mallId);

            return Promise.resolve(output);
        }
        catch (e) {
            return Promise.reject(e);
        }
    }
}