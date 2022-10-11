public class RBFMassApprovalActionSchedule implements Schedulable {
    public void execute(SchedulableContext ctx){
        String queueName = 'RBF PreApproval Queue';
        Database.executeBatch(new RBFMassApprovalActionBatch(queueName));
    }
}