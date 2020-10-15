import { ICardDTOInput } from '../interfaces/ICard';
import sequelize from '../loaders/sequelize';
import { QueryTypes } from 'sequelize';

export class cardRepository {
  async registerCard(output, input: ICardDTOInput): Promise<any> {
    try {
      return await sequelize.transaction(async function (t) {         
        var clientPaymentId =  await sequelize.query(`
          SELECT id 
            FROM 
          client            
          WHERE cpf = :cpf
          `, {
          replacements: {                        
            cpf:input.cpf
          }, type: QueryTypes.SELECT
        }); 
                           
        var client =  await sequelize.query(`
          SELECT id 
            FROM 
          client_mall cm
            JOIN client_payment cp ON (cm.client_id = cp.client_id AND cm.mall_id = cp.mall_id)            
          WHERE cp.client_id = ${clientPaymentId[0].id}
          `, {
          type: QueryTypes.SELECT
        });              
            
        await sequelize.query(`
          INSERT INTO "client_payment_credit_card" (client_payment_id, id_payment, first4_digits, last4_digits, expiration_month, expiration_year, holder_name, is_active, is_valid, is_verified)
          VALUES(${client[0].id}, :idPayment, :first4Digits,:last4Digits, :expirationMonth, :expirationYear,:holderName, :isActive,:isValid,:isVerified)
          `, {
          replacements: {    
            idPayment:output.id,                    
            first4Digits:output.first4_digits,
              last4Digits:output.last4_digits,
            expirationMonth:output.expiration_month,
            expirationYear:output.expiration_year,
            holderName:output.holder_name,
            isActive: output.is_active,
            isValid:output.is_valid,
            isVerified: output.is_verified
          }, type: QueryTypes.INSERT
        });              
        

        return Promise.resolve(output)
      })
    } catch (e) {
      return Promise.reject(e);
    }
  }

  async getCardId(clientId): Promise<any> {
    return await sequelize.query(`
      SELECT id_payment AS "id"
        FROM 
      client_payment_credit_card            
      WHERE id = ${clientId}
      `, {        
      type: QueryTypes.SELECT
    });  
  }

  async deleteCardAssociation(output, input: ICardDTOInput): Promise<any> {
    try {
      return await sequelize.transaction(async function (t) {                  
        await sequelize.query(`
          DELETE 
            FROM 
          "client_payment_credit_card"
          WHERE id = :clientId
          `, {
            replacements: {    
              clientId: input.clientId
            }, type: QueryTypes.DELETE
          });                            

        return Promise.resolve(output)
      })
    } catch (e) {
      return Promise.reject(e);
    }
  }

  async getAll(input: ICardDTOInput): Promise<any> {
    try {
      return await sequelize.transaction(async function (t) {                  
        var output = await sequelize.query(`
          SELECT 
            *
          FROM 
            "client_payment_credit_card"
          `, {
          type: QueryTypes.SELECT
        });                             
        return Promise.resolve(output)
      })
    } catch (e) {
      return Promise.reject(e);
    }
  }

}





